import { useSnackbar } from 'notistack';
import React, { createContext, useContext, useEffect, useState } from 'react';
import { useNavigate } from "react-router-dom";
import { useIndexer } from '../api/indexer';
import { translateEvent } from '../helpers/events';
import { generateMapNodes } from '../helpers/map';
import { BattleContext } from './battleContext';
import { DojoContext } from './dojoContext';
import { DraftContext } from './draftContext';
import { GAME_STATES, GameContext } from './gameContext';

// Create a context
const ReplayContext = createContext();

// Create a provider component
export const ReplayProvider = ({ children }) => {
  const dojo = useContext(DojoContext)
  const game = useContext(GameContext)
  const draft = useContext(DraftContext)
  const battle = useContext(BattleContext)

  const { getGameTxs } = useIndexer()

  const { enqueueSnackbar } = useSnackbar()
  const navigate = useNavigate()

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

    const receipt = await dojo.provider.waitForTransaction(txHash || txHashes[step], { retryInterval: 200 })
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
    await game.actions.loadGameDetails(_game)

    if (txs.length > 0) {
      fetchEvents(0, txs[0].tx_hash)
      fetchEvents(1, txs[1].tx_hash)
      setTxHashes(txs.map(tx => tx.tx_hash))
    } else {
      endReplay()
      enqueueSnackbar('Failed to load replay', { variant: 'error', anchorOrigin: { vertical: 'top', horizontal: 'center' } })
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

    navigate('/')
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
    if (step > 1) {
      setStep(prev => prev - 1)
    }
  }

  const spectateGame = (_game) => {
    setSpectatingGame(_game)
    game.actions.loadGameDetails(_game)
    navigate('/watch/' + _game.id)
  }

  const applyEvents = () => {
    if (appliedStep === step && !spectatingGame) return;

    const events = translatedEvents[step].reverse()

    const gameValues = events.find(e => e.componentName === 'Game')
    if (gameValues) {
      game.setGame({ ...gameValues, replay: true })

      if (!spectatingGame && gameValues.mapDepth === 0 && GAME_STATES[gameValues.state] === 'Map') {
        if (appliedStep === null || appliedStep < step) {
          setStep(prev => prev + 1)
        } else {
          setStep(prev => prev - 1)
        }
      }
    }

    const gameEffects = events.find(e => e.componentName === 'GameEffects')
    if (gameEffects) {
      game.setGameEffects(gameEffects)
    }

    const draftValues = events.find(e => e.componentName === 'Draft')
    if (draftValues) {
      draft.update.setCards(draftValues.cards.map(card => game.utils.getCard(card)))
      draft.update.setOptions(draftValues.options.map(option => game.utils.getCard(option)))

      if (draftValues.cards.length < game.getState.gameSettings.draft_size) {
        game.setGame({ state: 'Draft' })
      }
    }

    const mapValues = events.find(e => e.componentName === 'Map')
    if (mapValues) {
      const computedMap = generateMapNodes(mapValues.level, mapValues.seed, game.getState.gameSettings)
      game.setMap(computedMap);
    }

    const battleValues = events.find(e => e.componentName === 'Battle')
    const battleResourcesValues = events.find(e => e.componentName === 'BattleResources')

    if (battleValues) {
      battle.actions.startBattle(battleValues, battleResourcesValues)

      if (gameValues?.lastNodeId) {
        game.actions.updateMapStatus(gameValues.lastNodeId)
      }
    }

    setAppliedStep(step)
  }

  const getDraftCardSelection = () => {
    const event = translatedEvents[step + 1]
    const draftValues = event?.find(e => e.componentName === 'Draft')
    if (!draftValues) return null

    return draft.getState.options.findIndex(option => option.cardIndex === draftValues.cards[draftValues.cards.length - 1])
  }

  const getMapSelection = () => {
    const event = translatedEvents[step + 1]
    const gameValues = event?.find(e => e.componentName === 'Game')
    if (!gameValues) return null

    return gameValues.lastNodeId
  }

  const getPlayedCards = () => {
    const event = translatedEvents[step + 1]
    const nextBattleValues = event?.find(e => e.componentName === 'BattleResources')
    const battleValues = translatedEvents[step]?.find(e => e.componentName === 'BattleResources')
    if (!battleValues || !nextBattleValues) return null

    return battleValues.hand.filter(cardIndex => !nextBattleValues.hand.includes(cardIndex))
  }

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

