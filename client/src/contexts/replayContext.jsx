import { createClient } from "@dojoengine/torii-client";
import { useSnackbar } from 'notistack';
import React, { createContext, useCallback, useContext, useEffect, useState } from 'react';
import { RpcProvider } from "starknet";
import { dojoConfig } from "../../dojo.config";
import { getGameTxs, getSettings } from '../api/indexer';
import { CARD_DETAILS, formatBoard } from '../helpers/cards';
import { LAST_NODE_LEVEL } from "../helpers/constants";
import { translateEvent } from '../helpers/events';
import { generateMapNodes } from '../helpers/map';
import { BattleContext } from './battleContext';
import { DraftContext } from './draftContext';
import { GAME_STATES, GameContext } from './gameContext';

// Create a context
const ReplayContext = createContext();

// Create a provider component
export const ReplayProvider = ({ children }) => {
  const game = useContext(GameContext)
  const draft = useContext(DraftContext)
  const battle = useContext(BattleContext)

  const { enqueueSnackbar } = useSnackbar()
  const [toriiClient, setToriiClient] = useState(null)

  let provider = new RpcProvider({ nodeUrl: dojoConfig.rpcUrl });

  const [txHashes, setTxHashes] = useState([]);
  const [step, setStep] = useState(0)
  const [appliedStep, setAppliedStep] = useState(null)
  const [translatedEvents, setTranslatedEvents] = useState({})
  const [loadingReplay, setLoadingReplay] = useState(false)

  const [spectatingGame, setSpectatingGame] = useState(null)

  useEffect(() => {
    if (translatedEvents[step]) {
      applyEvents()
      fetchEvents(step + 2)
    }
  }, [step, translatedEvents])

  const fetchEvents = async (step, txHash) => {
    if (translatedEvents[step] && !spectatingGame) {
      return
    }

    if (!txHash && !txHashes[step]) {
      return
    }

    const receipt = await provider.waitForTransaction(txHash || txHashes[step], { retryInterval: 100 })
    if (!receipt) {
      enqueueSnackbar('Failed to load replay', { variant: 'error', anchorOrigin: { vertical: 'bottom', horizontal: 'right' } })
      endReplay()
    }

    const events = receipt.events.map(event => translateEvent(event)).filter(Boolean)
    setTranslatedEvents(prev => ({ ...prev, [step]: events }))
  }

  const startReplay = async (_game) => {
    setLoadingReplay(true)

    let txs = await getGameTxs(_game.id)
    let settings = await getSettings(_game.settingsId)
    game.setGameSettings(settings)

    if (txs.length > 0) {
      fetchEvents(0, txs[0].tx_hash)
      fetchEvents(1, txs[1].tx_hash)
      setTxHashes(txs.map(tx => tx.tx_hash))
    } else {
      enqueueSnackbar('Failed to load replay', { variant: 'error', anchorOrigin: { vertical: 'bottom', horizontal: 'right' } })
    }
  }

  const endReplay = () => {
    setStep(0)
    setAppliedStep(null)
    setTxHashes([])
    setTranslatedEvents({})
    setSpectatingGame(null)
    setLoadingReplay(false)

    battle.utils.resetBattleState()
    game.endGame()
  }

  const nextStep = async () => {
    if (!translatedEvents[step + 1]) return;

    if (step < txHashes.length - 1) {
      setStep(prev => prev + 1)
    } else {
      endReplay()
    }
  }

  const previousStep = async () => {
    if (step > 0) {
      setStep(prev => prev - 1)
    }
  }

  const spectateGame = (game) => {   
    setSpectatingGame(game)
  }

  const applyEvents = () => {
    if (appliedStep === step && !spectatingGame) return;

    const events = translatedEvents[step]

    const gameValues = events.find(e => e.componentName === 'Game')
    if (gameValues) {
      game.setGame({ ...gameValues, replay: true })

      if (!spectatingGame && gameValues.mapDepth === LAST_NODE_LEVEL && GAME_STATES[gameValues.state] === 'Map') {
        if (appliedStep < step) {
          setStep(prev => prev + 1)
        } else {
          setStep(prev => prev - 1)
        }
      }
    }

    const draftValues = events.find(e => e.componentName === 'Draft')
    if (draftValues) {
      draft.update.setCards(draftValues.cards.map(card => CARD_DETAILS(card)))
      draft.update.setOptions(draftValues.options.map(option => CARD_DETAILS(option)))

      if (draftValues.cards.length < game.getState.gameSettings.draft_size) {
        game.setGame({ state: 'Draft' })
      }
    }

    const mapValues = events.find(e => e.componentName === 'Map')
    if (mapValues) {
      const computedMap = generateMapNodes(mapValues.level, mapValues.seed)
      game.setMap(computedMap);
    }

    const battleValues = events.find(e => e.componentName === 'Battle')
    if (battleValues) {
      battle.actions.startBattle(battleValues)

      if (gameValues?.lastNodeId) {
        game.actions.updateMapStatus(gameValues.lastNodeId)
      }
    }

    const boardValues = events.find(e => e.componentName === 'Board')
    if (boardValues) {
      battle.utils.setBoard(formatBoard(boardValues))
    }

    setAppliedStep(step)
  }

  const getDraftCardSelection = () => {
    const event = translatedEvents[step + 1]
    const draftValues = event?.find(e => e.componentName === 'Draft')
    if (!draftValues) return null

    return draft.getState.options.findIndex(option => option.cardId === draftValues.cards[draftValues.cards.length - 1])
  }

  const getMapSelection = () => {
    const event = translatedEvents[step + 1]
    const gameValues = event?.find(e => e.componentName === 'Game')
    if (!gameValues) return null

    return gameValues.lastNodeId
  }

  const getPlayedCards = () => {
    const event = translatedEvents[step + 1]
    const nextBattleValues = event?.find(e => e.componentName === 'Battle')
    const battleValues = translatedEvents[step]?.find(e => e.componentName === 'Battle')
    if (!battleValues || !nextBattleValues) return null

    return battleValues.hand.filter(card => !nextBattleValues.hand.includes(card))
  }

  const setupToriiClient = async () => {
    const client = await createClient({
      rpcUrl: dojoConfig.rpcUrl,
      toriiUrl: dojoConfig.toriiUrl,
      relayUrl: "",
      worldAddress: dojoConfig.manifest.world.address || "",
    });

    setToriiClient(client);
  };

  const setupEntitySync = useCallback(async () => {
    try {
      return await toriiClient?.onEventMessageUpdated(
        [],
        false,
        (_, data) => {
          console.log('data', data)
          if (Boolean(data[`${dojoConfig.namespace}-GameActionEvent`])) {
            let gameId = data[`${dojoConfig.namespace}-GameActionEvent`]["game_id"].value

            if (parseInt(gameId, 16) === spectatingGame?.id) {
              fetchEvents(step, data[`${dojoConfig.namespace}-GameActionEvent`]["tx_hash"].value)
            }
          }
        }
      );
    } catch (error) {
      console.log(error)
      throw error;
    }
  }, [toriiClient, spectatingGame?.id]);

  useEffect(() => {
    let unsubscribe = undefined;

    setupEntitySync().then((sync) => {
      unsubscribe = sync;
    }).catch((error) => {
      console.error("Error setting up entity sync:", error);
    });

    return () => {
      if (unsubscribe) {
        unsubscribe.cancel();
      }
    };
  }, [setupEntitySync]);

  useEffect(() => {
    setupToriiClient()
  }, [])

  return (
    <ReplayContext.Provider value={{
      startReplay,
      endReplay,
      nextStep,
      previousStep,
      getDraftCardSelection,
      getMapSelection,
      getPlayedCards,
      spectateGame,

      loadingReplay,
      translatedEvents,
      spectatingGame
    }}>
      {children}
    </ReplayContext.Provider>
  );
};

export const useReplay = () => {
  return useContext(ReplayContext);
};

