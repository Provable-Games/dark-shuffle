import React, { createContext, useContext, useState, useEffect } from "react";
import { getDraft } from "../api/indexer";
import { delay } from "../helpers/utilities";
import { DojoContext } from "./dojoContext";
import { GameContext } from "./gameContext";

export const DraftContext = createContext()

export const DraftProvider = ({ children }) => {
  const dojo = useContext(DojoContext)
  const game = useContext(GameContext)
  const { gameSettings, gameCards } = game.getState

  const [gameData, setGameData] = useState()
  const [pendingCard, setPendingCard] = useState()

  const [options, setOptions] = useState([])
  const [cards, setCards] = useState([])

  useEffect(() => {
    if (gameData && gameSettings?.start_health && gameCards?.length > 0) {
      startDraft()
    }
  }, [gameData, gameSettings, gameCards])

  const initializeState = () => {
    setPendingCard()
    setOptions([])
    setCards([])
    game.setStartStatus('Minting Game Token')
  }

  const prepareStartingGame = async (tokenData) => {
    setGameData(tokenData)
    await game.utils.initializeGameSettings(tokenData.settingsId)
  }

  const startDraft = async () => {
    initializeState()

    game.setStartStatus('Shuffling Cards')

    const txs = []
    txs.push({
      contractName: "game_systems",
      entrypoint: "start_game",
      calldata: [gameData.tokenId]
    })

    const res = await dojo.executeTx(txs, true)
    game.setStartStatus()

    if (res) {
      const gameValues = res.find(e => e.componentName === 'Game')
      const draftValues = res.find(e => e.componentName === 'Draft')

      game.setGame({ ...gameValues, playerName: gameData.playerName })
      setOptions(draftValues.options.map(option => game.utils.getCard(option)))
      setCards(draftValues.cards.map(card => game.utils.getCard(card)))
    }
  }

  const selectCard = async (optionId) => {
    if (game.values.replay) {
      return
    }

    setPendingCard(optionId)

    if (game.values.isDemo) {
      await delay(500)
    }

    const res = await dojo.executeTx([{ contractName: "draft_systems", entrypoint: "pick_card", calldata: [game.values.gameId, optionId] }], cards.length < gameSettings.draft_size - 1)

    if (res) {
      const gameValues = res.find(e => e.componentName === 'Game')
      const draftValues = res.find(e => e.componentName === 'Draft')

      setCards(draftValues.cards.map(card => game.utils.getCard(card)))
      setOptions(draftValues.options.map(option => game.utils.getCard(option)))

      if (gameValues) {
        game.setGame(gameValues)
      }
    }

    setPendingCard()
  }

  const fetchDraft = async (gameId) => {
    let data = await getDraft(gameId);

    setCards(data.cards.map(card => game.utils.getCard(card)));
    setOptions(data.options.map(option => game.utils.getCard(option)));
  }

  return (
    <DraftContext.Provider
      value={{
        actions: {
          prepareStartingGame,
          selectCard,
          fetchDraft
        },

        update: {
          setOptions,
          setCards
        },

        getState: {
          cards,
          options,
          pendingCard,
        },
      }}
    >
      {children}
    </DraftContext.Provider>
  );
};