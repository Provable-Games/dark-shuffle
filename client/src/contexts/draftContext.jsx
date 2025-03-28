import React, { createContext, useContext, useState } from "react";
import { getDraft, getSettings } from "../api/indexer";
import { CARD_DETAILS } from "../helpers/cards";
import { delay } from "../helpers/utilities";
import { DojoContext } from "./dojoContext";
import { GameContext } from "./gameContext";

export const DraftContext = createContext()

export const DraftProvider = ({ children }) => {
  const dojo = useContext(DojoContext)
  const game = useContext(GameContext)
  const { gameSettings } = game.getState

  const [pendingCard, setPendingCard] = useState()

  const [options, setOptions] = useState([])
  const [cards, setCards] = useState([])

  const initializeState = () => {
    setPendingCard()
    setOptions([])
    setCards([])
    game.setStartStatus('Minting Game Token')
  }

  const startDraft = async (tokenData) => {
    initializeState()

    game.setStartStatus('Shuffling Cards')

    const txs = []
    txs.push({
      contractName: "game_systems",
      entrypoint: "start_game",
      calldata: [tokenData.tokenId]
    })

    const res = await dojo.executeTx(txs, true)
    game.setStartStatus()

    if (res) {
      const gameValues = res.find(e => e.componentName === 'Game')
      const draftValues = res.find(e => e.componentName === 'Draft')

      let settings = await getSettings(tokenData.settingsId)
      if (!settings) {
        return false
      }

      game.setGameSettings(settings)

      game.setGame({ ...gameValues, playerName: tokenData.playerName })
      setOptions(draftValues.options.map(option => CARD_DETAILS(option)))
      return true
    }

    return false
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

      setCards(draftValues.cards.map(card => CARD_DETAILS(card)))
      setOptions(draftValues.options.map(option => CARD_DETAILS(option)))

      if (gameValues) {
        game.setGame(gameValues)
      }
    }

    setPendingCard()
  }

  const fetchDraft = async (gameId) => {
    let data = await getDraft(gameId);

    setCards(data.cards.map(card => CARD_DETAILS(card)));
    setOptions(data.options.map(option => CARD_DETAILS(option)));
  }

  return (
    <DraftContext.Provider
      value={{
        actions: {
          startDraft,
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
          status
        },
      }}
    >
      {children}
    </DraftContext.Provider>
  );
};