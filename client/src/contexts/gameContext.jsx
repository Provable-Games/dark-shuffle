import React, { createContext, useContext, useState } from "react";
import { generateMapNodes } from "../helpers/map";
import { DojoContext } from "./dojoContext";

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
  const [startStatus, setStartStatus] = useState()

  const [values, setValues] = useState({ ...GAME_VALUES })
  const [gameSettings, setGameSettings] = useState({})
  const [gameEffects, setGameEffects] = useState({})

  const [map, setMap] = useState(null)
  const [score, setScore] = useState()

  const setGame = (values) => {
    if (!isNaN(values.state || 0)) {
      values.state = GAME_STATES[values.state]
    }

    setValues(prev => ({ ...prev, ...values }))
  }

  const endGame = () => {
    setValues({ ...GAME_VALUES })
    setGameEffects({})
    setGameSettings({})
    setMap(null)
    setScore()
  }

  const mintFreeGame = async (settingsId = 0) => {
    const res = await dojo.executeTx([{ contractName: "game_systems", entrypoint: "mint", calldata: [
      '0x' + dojo.playerName.split('').map(char => char.charCodeAt(0).toString(16)).join(''),
      settingsId,
      1,
      1,
      dojo.address
    ] }])

    const tokenMetadata = res.find(e => e.componentName === 'TokenMetadata')
    return tokenMetadata
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

    const res = await dojo.executeTx([{ contractName: "map_systems", entrypoint: "generate_tree", calldata: [values.gameId] }], true);

    if (res) {
      const mapValues = res.find(e => e.componentName === 'Map')
      const gameValues = res.find(e => e.componentName === 'Game')

      const computedMap = generateMapNodes(mapValues.level, mapValues.seed)

      setMap(computedMap);
      setGame(gameValues);
    }
  }

  return (
    <GameContext.Provider
      value={{
        getState: {
          map,
          gameEffects,
          gameSettings,
          startStatus,
        },

        values,
        score,

        setStartStatus,
        setGame,
        endGame,
        setScore,
        setGameEffects,
        setGameSettings,
        setMap,

        actions: {
          generateMap,
          updateMapStatus,
          mintFreeGame,
        }
      }}
    >
      {children}
    </GameContext.Provider>
  );
};