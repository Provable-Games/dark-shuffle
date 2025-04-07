import React, { createContext, useContext, useEffect, useState } from "react";
import { generateMapNodes } from "../helpers/map";
import { DojoContext } from "./dojoContext";
import { getCardDetails, getRecommendedSettings, getSettings } from "../api/indexer";
import { useSnackbar } from "notistack";

export const GameContext = createContext()

export const GAME_STATES = {
  0: 'Draft',
  1: 'Battle',
  2: 'Map',
  3: 'None',
}

const GAME_VALUES = {
  gameId: null,
  state: GAME_STATES[3],
  replay: false
}

export const GameProvider = ({ children }) => {
  const dojo = useContext(DojoContext)
  const { enqueueSnackbar } = useSnackbar()

  const [loading, setLoading] = useState(false)
  const [loadingProgress, setLoadingProgress] = useState(0)

  const [tokenData, setTokenData] = useState({})
  const [values, setValues] = useState({ ...GAME_VALUES })
  const [gameSettings, setGameSettings] = useState({})
  const [gameCards, setGameCards] = useState([])
  const [gameEffects, setGameEffects] = useState({})

  const [map, setMap] = useState(null)
  const [score, setScore] = useState()

  const [recommendedSettings, setRecommendedSettings] = useState([])

  useEffect(() => {
    const fetchRecommendedSettings = async () => {
      const settings = await getRecommendedSettings()
      setRecommendedSettings(settings)
    }

    fetchRecommendedSettings()
  }, [])

  useEffect(() => {
    if (values.gameId) {
      setLoading(false);
    }
  }, [values.gameId])

  const setGame = (values) => {
    if (!isNaN(values.state || 0)) {
      values.state = GAME_STATES[values.state]
    }

    setValues(prev => ({ ...prev, ...values }))
  }

  const endGame = () => {
    setLoading(false)
    setLoadingProgress(0)
    setTokenData({})
    setValues({ ...GAME_VALUES })
    setGameEffects({})
    setGameCards([])
    setGameSettings({})
    setMap(null)
    setScore()
  }

  const mintFreeGame = async (settingsId = 0) => {
    setLoading(true)
    setLoadingProgress(45)

    try {
      const res = await dojo.executeTx([{
        contractName: "game_systems", entrypoint: "mint", calldata: [
          '0x' + dojo.playerName.split('').map(char => char.charCodeAt(0).toString(16)).join(''),
          settingsId,
          1,
          1,
          dojo.address
        ]
      }])

      const tokenMetadata = res.find(e => e.componentName === 'TokenMetadata')
      return tokenMetadata
    } catch (ex) {
      handleError()
    }
  }

  const loadGameDetails = async (tokenData) => {
    setLoading(true)
    setLoadingProgress(55)

    try {
      setTokenData(tokenData)

      const settings = await getSettings(tokenData.settingsId)
      const cardDetails = await getCardDetails(settings.card_ids)

      setGameSettings(settings)
      setGameCards(cardDetails)
    } catch (ex) {
      handleError()
    }

  }

  const updateMapStatus = (nodeId) => {
    setMap(prev => prev.map(node => {
      if (node.nodeId === nodeId) {
        return { ...node, status: 1, active: false }
      }

      if (node.parents.find(parent => parent === nodeId)) {
        return { ...node, active: true }
      }

      if (node.active && node.status !== 1) {
        return { ...node, active: false }
      }
      return node
    }))
  }

  const generateMap = async () => {
    if (values.replay) {
      return
    }

    const res = await dojo.executeTx([{ contractName: "game_systems", entrypoint: "generate_tree", calldata: [values.gameId] }], true);

    if (res) {
      const mapValues = res.find(e => e.componentName === 'Map')
      const gameValues = res.find(e => e.componentName === 'Game')

      const computedMap = generateMapNodes(mapValues.level, mapValues.seed, gameSettings)

      setMap(computedMap);
      setGame(gameValues);
    }
  }

  const getCard = (cardIndex, id) => {
    return {
      id,
      cardIndex,
      ...gameCards.find(card => Number(card.cardId) === Number(gameSettings.card_ids[cardIndex])),
    }
  }

  const handleError = () => {
    enqueueSnackbar('Failed to start game', { variant: 'error' })
    endGame();
  }

  return (
    <GameContext.Provider
      value={{
        getState: {
          map,
          gameEffects,
          gameSettings,
          gameCards,
          loading,
          tokenData,
          loadingProgress
        },

        values,
        score,
        recommendedSettings,

        setGame,
        endGame,
        setScore,
        setGameEffects,
        setGameSettings,
        setMap,
        setTokenData,
        setLoading,
        setLoadingProgress,

        utils: {
          getCard,
          handleError
        },

        actions: {
          generateMap,
          updateMapStatus,
          loadGameDetails,
          mintFreeGame
        }
      }}
    >
      {children}
    </GameContext.Provider>
  );
};