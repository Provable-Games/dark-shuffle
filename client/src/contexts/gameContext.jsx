import { useSnackbar } from "notistack";
import React, { createContext, useContext, useEffect, useState } from "react";
import { getCardDetails, getRecommendedSettings, getSettings } from "../api/indexer";
import { generateMapNodes } from "../helpers/map";
import { DojoContext } from "./dojoContext";
import { fetchQuestTarget } from "../api/starknet";
import { VRF_PROVIDER_ADDRESS } from "../helpers/constants";
import { CallData } from "starknet";
import { getContractByName } from "@dojoengine/core";
import { dojoConfig } from "../../dojo.config";

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

  const [loading, setLoading] = useState(true)
  const [loadingProgress, setLoadingProgress] = useState(0)

  const [GG_questMode, setQuestMode] = useState(false)
  const [GG_questTargetScore, setQuestTargetScore] = useState(0)

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

  useEffect(() => {
    const getQuestTarget = async () => {
      const questTarget = await fetchQuestTarget(values.gameId)
      setValues(prev => ({ ...prev, questTarget }))
    }

    if (values.gameId && tokenData.eternumQuest) {
      getQuestTarget()
    }
  }, [tokenData.eternumQuest, values.gameId])

  useEffect(() => {
    if (values.gameId && GG_questMode) {
      setValues(prev => ({ ...prev, questTarget: GG_questTargetScore }))
    }
  }, [GG_questMode, values.gameId, GG_questTargetScore])

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
      await loadGameDetails(tokenMetadata)

      return tokenMetadata
    } catch (ex) {
      console.log(ex)
      handleError()
    }
  }

  const startBattleDirectly = async (gameId) => {
    setLoadingProgress(55)

    let game_address = getContractByName(dojoConfig.manifest, dojoConfig.namespace, "game_systems")?.address
    let requestRandom = {
      contractAddress: VRF_PROVIDER_ADDRESS,
      entrypoint: 'request_random',
      calldata: CallData.compile({
        caller: game_address,
        source: { type: 0, address: dojo.address }
      })
    }

    const txs = [
      requestRandom,
      { contractName: "game_systems", entrypoint: "start_game", calldata: [gameId] },
      requestRandom,
      { contractName: "game_systems", entrypoint: "generate_tree", calldata: [gameId] },
      requestRandom,
      { contractName: "game_systems", entrypoint: "select_node", calldata: [gameId, 1] }
    ]

    await dojo.executeTx(txs, false)
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
      console.log(ex)
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
          loadingProgress,
          GG_questMode,
          GG_questTargetScore
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
          handleError,
          setQuestMode,
          setQuestTargetScore
        },

        actions: {
          generateMap,
          updateMapStatus,
          loadGameDetails,
          mintFreeGame,
          startBattleDirectly
        }
      }}
    >
      {children}
    </GameContext.Provider>
  );
};