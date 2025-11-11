import { useSnackbar } from "notistack";
import React, { createContext, useContext, useEffect, useState } from "react";
import { useIndexer } from "../api/indexer";
import { generateMapNodes } from "../helpers/map";
import { DojoContext } from "./dojoContext";
import { VRF_PROVIDER_ADDRESS } from "../helpers/constants";
import { CairoOption, CairoOptionVariant, CallData } from "starknet";
import { getContractByName } from "@dojoengine/core";
import { useDynamicConnector } from "./starknet";
import { stringToFelt } from "../helpers/utilities";

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
  const { currentNetworkConfig } = useDynamicConnector();
  const dojo = useContext(DojoContext)
  const { enqueueSnackbar } = useSnackbar()
  const { getSettings, getCardDetails, getRecommendedSettings } = useIndexer()

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
      window.history.replaceState(null, '', `/play/${values.gameId}`)
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

  /**
   * Mints a new game token.
   * @param account The Starknet account
   * @param name The name of the game
   * @param settingsId The settings ID for the game
   */
  const mintFreeGame = async (settingsId = 0) => {
    try {
      let receipt = await dojo.executeTx(
        [
          {
            contractAddress: getContractByName(currentNetworkConfig.manifest, currentNetworkConfig.namespace, "game_systems")?.address,
            entrypoint: "mint_game",
            calldata: CallData.compile([
              new CairoOption(CairoOptionVariant.Some, stringToFelt(dojo.playerName)),
              new CairoOption(CairoOptionVariant.Some, settingsId),
              1, // start
              1, // end
              1, // objective_ids
              1, // context
              1, // client_url
              1, // renderer_address
              dojo.address,
              false, // soulbound
            ]),
          },
        ],
        false,
        true
      );

      const tokenMetadataEvent = receipt.events.find(
        (event) => event.data.length === 14
      );

      let gameId = parseInt(tokenMetadataEvent.data[1], 16)
      let tokenMetaData = await getTokenMetadata(gameId)

      await loadGameDetails(tokenMetaData)

      return gameId
    } catch (error) {
      console.log(error)
      handleError()
    }
  };

  const startBattleDirectly = async (gameId) => {
    setLoadingProgress(55)

    let game_address = getContractByName(currentNetworkConfig.manifest, currentNetworkConfig.namespace, "game_systems")?.address
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
      { contractAddress: game_address, entrypoint: "start_game", calldata: [gameId] },
      requestRandom,
      { contractAddress: game_address, entrypoint: "generate_tree", calldata: [gameId] },
      requestRandom,
      { contractAddress: game_address, entrypoint: "select_node", calldata: [gameId, 1] }
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

    const res = await dojo.executeTx([{
      contractAddress: getContractByName(currentNetworkConfig.manifest, currentNetworkConfig.namespace, "game_systems")?.address,
      entrypoint: "generate_tree",
      calldata: [values.gameId]
    }], true);

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