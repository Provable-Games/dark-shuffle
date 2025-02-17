import { useSnackbar } from "notistack";
import React, { createContext, useContext, useEffect, useState } from "react";
import { isMobile } from 'react-device-detect';
import { attackEffect } from "../battle/attackUtils";
import { deathEffect } from "../battle/deathUtils";
import { GET_MONSTER } from "../battle/monsterUtils";
import { endOfTurnMonsterEffect } from "../battle/monsterAbility";
import { summonEffect } from "../battle/summonUtils";
import { CARD_DETAILS, formatBoard, tags } from "../helpers/cards";
import { ADVENTURER_ID } from "../helpers/constants";
import { AnimationContext } from "./animationHandler";
import { DojoContext } from "./dojoContext";
import { GameContext } from "./gameContext";
import { delay } from "../helpers/utilities";
import { getBattleState } from "../api/indexer";
import { spellEffect } from "../battle/spellUtils";

export const BattleContext = createContext()

export const BattleProvider = ({ children }) => {
  const dojo = useContext(DojoContext)
  const game = useContext(GameContext)
  const { gameEffects, gameSettings } = game.getState

  const animationHandler = useContext(AnimationContext)

  const { enqueueSnackbar } = useSnackbar()
  const [resettingState, setResettingState] = useState(false)

  const [values, setValues] = useState({})
  const [updatedValues, setUpdatedValues] = useState()
  const [updatedBoard, setUpdatedBoard] = useState()

  const [hand, setHand] = useState([])
  const [board, setBoard] = useState([])
  const [deck, setDeck] = useState([])
  const [battleEffects, setBattleEffects] = useState()
  const [roundStats, setRoundStats] = useState({})

  const [actions, setActions] = useState([])
  const [turnEnded, setTurnEnded] = useState(false)

  const [pendingTx, setPendingTx] = useState(false)
  const [endState, setEndState] = useState()

  useEffect(() => {
    if (animationHandler.completed.length < 1) {
      return
    }

    const animation = animationHandler.completed[0]

    if (animation.type === 'monsterAbility') {
      monsterAttack()
    }

    if (animation.type === 'monsterAttack') {
      monsterAttackResult()
    }

    if (animation.type === 'creatureAttack') {
      creatureAttack(animation.creatureId)
    }

    if (animation.type === 'creatureDead') {
      creatureDeath(animation.creature)
    }

    animationHandler.consumeCompleted()
    // eslint-ignore-next-line react-hooks/exhaustive-deps
  }, [animationHandler.completed])

  useEffect(() => {
    if (turnEnded) {
      let creature = board.find(creature => !creature.attacked)

      if (creature) {
        animationHandler.addAnimation('creature', {
          type: 'attack',
          creatureId: creature.id,
          creature,
          position: getCreaturePosition(creature.id),
          targetPosition: getMonsterPosition(),
        })
      }

      else if (board.find(creature => creature.health < 1 && !creature.dead)) {
        cleanBoard()
      }

      else if (!board.find(creature => creature.health < 1 || creature.dead)) {
        setTurnEnded(false)

        animationHandler.addAnimation('monster', {
          type: 'ability',
          position: getMonsterPosition(),
        })
      }
    }
  }, [turnEnded, board])

  useEffect(() => {
    if (values.monsterHealth < 1 && endState) {
      endBattle()
    }
  }, [values.monsterHealth, endState])

  const resetBattleState = () => {
    setValues({})
    setBattleEffects()
    setHand([])
    setDeck([])
    setBoard([])
    setActions([])
    setTurnEnded(false)
    setEndState()
    setRoundStats({})
  }

  const submitBattleActions = async () => {
    if (game.values.replay) {
      return
    }

    setPendingTx(true)

    const res = await dojo.executeTx([{ contractName: "battle_systems", entrypoint: "battle_actions", calldata: [game.values.gameId, values.battleId, [...actions, [1]]] }], true)

    if (!res) {
      return;
    }

    const gameValues = res.find(e => e.componentName === 'Game')
    const gameEffects = res.find(e => e.componentName === 'GameEffects')
    const leaderboard = res.find(e => e.componentName === 'Leaderboard')
    const battleValues = res.find(e => e.componentName === 'Battle')
    const board = res.find(e => e.componentName === 'Board')

    setUpdatedValues(battleValues)

    if (board) {
      setUpdatedBoard(formatBoard(board))
    }

    if (gameValues) {
      setEndState({ gameValues, leaderboard, gameEffects })
    }

    setPendingTx(false)
  }

  const endTurn = async () => {
    await submitBattleActions()

    if (gameEffects.heroCardHeal) {
      healHero(hand.length)
    }

    setRoundStats({
      monsterStartHealth: values.monsterHealth,
      creaturesPlayed: 0,
      creatureAttackCount: 0
    })

    setTurnEnded(true)
  }

  const startBattle = async (battle) => {
    animationHandler.resetAnimationHandler()

    setValues({
      battleId: battle.battleId,
      round: battle.round,
      deckIndex: battle.deckIndex,
      ...battle.hero,
      ...battle.monster,
      monsterType: GET_MONSTER(battle.monster.monsterId).monsterType
    })
    setBattleEffects({ ...battle.battleEffects })
    setHand(battle.hand.map((card, i) => CARD_DETAILS(card, i + 1)))
    setDeck(battle.deck)
    setBoard([])
    setActions([])
    setRoundStats({
      monsterStartHealth: battle.monster.monsterHealth,
      creaturesPlayed: 0,
      creatureAttackCount: 0
    })

    setEndState()
  }

  const summonCreature = (creature) => {
    let cost = getCardCost(creature);

    if (cost > values.heroEnergy) {
      return enqueueSnackbar('Not enough energy', { variant: 'warning' })
    }

    if (board.length > 5) {
      return enqueueSnackbar('Board is full', { variant: 'warning' })
    }

    setValues(prev => ({ ...prev, heroEnergy: prev.heroEnergy - cost }))

    summonEffect({
      creature, values, board, battleEffects, setBattleEffects, gameEffects,
      updateBoard, reduceMonsterAttack, increaseEnergy, damageMonster, setValues,
      damageHero, healHero, roundStats, setRoundStats
    })

    setBoard(prev => [...prev, { ...creature, id: (prev[prev.length - 1]?.id || 0) + 1 }])
    setHand(prev => prev.filter(card => card.id !== creature.id))
    setActions(prev => [...prev, [0, creature.cardId]])
  }

  const castSpell = (spell) => {
    let cost = spell.cost;

    if (cost > values.heroEnergy) {
      return enqueueSnackbar('Not enough energy', { variant: 'warning' })
    }

    setValues(prev => ({ ...prev, heroEnergy: prev.heroEnergy - cost }))

    spellEffect({
      spell, values, board, healHero, updateBoard, reduceMonsterAttack,
      increaseEnergy, damageMonster, battleEffects, setBattleEffects
    })

    setHand(prev => prev.filter(card => card.id !== spell.id))
    setActions(prev => [...prev, [0, spell.cardId]])
  }

  const startNewTurn = () => {
    setValues({
      battleId: updatedValues.battleId,
      round: updatedValues.round,
      deckIndex: updatedValues.deckIndex,
      ...updatedValues.hero,
      ...updatedValues.monster,
      monsterType: GET_MONSTER(updatedValues.monster.monsterId).monsterType
    })
    setHand(updatedValues.hand.map((card, i) => CARD_DETAILS(card, i + 1)))
    setBoard(prev => prev.map(creature => ({ ...creature, attacked: false })))
    setDeck(updatedValues.deck)

    setActions([])
    setUpdatedValues()
    setRoundStats({})
  }

  const endBattle = async () => {
    setTurnEnded(false)

    if (endState.gameValues.heroHealth < 1) {
      game.setScore(Math.max(1, endState.gameValues.heroXp))
    } else {
      await delay(1000)
      game.setGame(endState.gameValues)
      game.setGameEffects(endState.gameEffects)
      game.actions.updateMapStatus(endState.gameValues.lastNodeId)
      resetBattleState()
    }
  }

  const monsterAttack = () => {
    endOfTurnMonsterEffect({
      setValues, values, setHand, setBoard, board,
      damageHero, hand, roundStats, damageCreature
    })

    animationHandler.addAnimation('monster', {
      type: 'attack',
      position: getMonsterPosition(),
      targetPosition: getCreaturePosition(ADVENTURER_ID),
    })
  }

  // BOARD UTILS
  const updateBoardCreature = (creatureId, update) => {
    const updatedBoard = board.map(creature => creature.id === creatureId ? { ...creature, ...update } : creature)
    setBoard(updatedBoard)
  }

  const updateBoard = (creatureType, attack, health) => {
    const updatedBoard = board.map(creature => (creature.creatureType === creatureType || creatureType === tags.ALL)
      ? { ...creature, attack: creature.attack + attack, health: creature.health + health }
      : creature
    )
    setBoard(updatedBoard)
  }

  const cleanBoard = () => {
    setBoard(prev => prev.map(creature => creature.health < 1 ? { ...creature, dead: true } : creature))
  }

  // MONSTER UTILS
  const damageMonster = (amount, creatureType) => {
    amount += battleEffects.enemyMarks

    if (amount < 1) {
      return;
    }

    if (values.monsterId == 75 && creatureType == tags.HUNTER) {
      amount -= 1;
    } else if (values.monsterId == 70 && creatureType == tags.MAGICAL) {
      amount -= 1;
    } else if (values.monsterId == 65 && creatureType == tags.BRUTE) {
      amount -= 1;
    }

    setValues(prev => ({ ...prev, monsterHealth: Math.max(0, prev.monsterHealth - amount) }));
  }

  const reduceMonsterAttack = (amount) => {
    setValues(prev => ({ ...prev, monsterAttack: Math.max(1, prev.monsterAttack - amount) }))
  }

  const monsterAttackResult = async () => {
    damageHero(values.monsterAttack)

    if (endState) {
      return endBattle()
    }

    startNewTurn()
  }

  // CREATURE UTILS
  const damageCreature = (creature, amount) => {
    if (values.monsterId == 74 && creature.creatureType == tags.HUNTER) {
      amount += 1;
    } else if (values.monsterId == 69 && creature.creatureType == tags.MAGICAL) {
      amount += 1;
    } else if (values.monsterId == 64 && creature.creatureType == tags.BRUTE) {
      amount += 1;
    }

    if (creature.cardId == 27) {
      amount -= 1;

      if (board.filter(creature => creature.creatureType == tags.BRUTE).length > 1) {
        amount -= 1;
      }
    }

    creature.health -= amount;
    updateBoardCreature(creature.id, { ...creature })
  }

  const creatureAttack = (creatureId) => {
    let creature = { ...board.find(creature => creature.id === creatureId) }

    let extraDamage = attackEffect({ creature, values, board, setBattleEffects, reduceMonsterAttack, healHero })

    damageMonster(creature.attack + extraDamage, creature.creatureType)

    if (creature.cardId === 46) {
      creature.attack += 1;
    }

    creature.attacked = true;

    setRoundStats(prev => ({ ...prev, creatureAttackCount: prev.creatureAttackCount + 1 }))
    damageCreature(creature, values.monsterAttack)
  }

  const creatureDeathEffect = (creature) => {
    deathEffect({
      creature, values, board, battleEffects, setBattleEffects,
      updateBoard, reduceMonsterAttack, healHero, damageMonster
    })
  }

  // HERO UTILS
  const increaseEnergy = (amount) => {
    if (amount < 1) return;

    setValues(prev => ({ ...prev, heroEnergy: prev.heroEnergy + amount }))
  }

  const healHero = (amount) => {
    if (amount < 1) {
      return;
    }

    setValues(prev => ({ ...prev, heroHealth: Math.min(255, prev.heroHealth + amount) }))
  }

  const damageHero = (amount) => {
    amount -= battleEffects.heroDmgReduction

    if (amount < 1) {
      return;
    }

    setValues(prev => ({ ...prev, heroHealth: Math.max(0, prev.heroHealth - amount) }))
  }

  // HAND UTILS
  const getCardCost = (card) => {
    let cost = card.cost

    if (roundStats.creaturesPlayed < 1) {
      cost -= gameEffects.firstCreatureCost ?? 0;
    }

    return cost
  }

  // POSITION UTILS
  const getMonsterPosition = () => {
    if (isMobile) {
      return {
        x: window.innerWidth / 2,
        y: (window.innerHeight - 56 - 150) * 0.95
      }
    }

    return {
      x: window.innerWidth / 2,
      y: (window.innerHeight - 56 - 200) * 0.95
    }
  }

  const getCreaturePosition = (id) => {
    if (id === ADVENTURER_ID) {
      return {
        x: window.innerWidth / 2,
        y: (window.innerHeight - 56 - 200) * 0.50
      }
    }

    const index = board.findIndex(creature => creature.id === id)
    const startCoord = (window.innerWidth / 2) - (board.length * 136 - 16) / 2

    return {
      x: startCoord + (index * 136) + 60,
      y: (window.innerHeight - 56 - 200) * 0.69
    }
  }

  const fetchBattleState = async (battleId, gameId) => {
    setResettingState(true)
    let data = await getBattleState(parseInt(battleId), parseInt(gameId))

    setValues({
      battleId,

      round: data.battle.round,
      heroHealth: data.battle.hero.health,
      heroEnergy: data.battle.hero.energy,

      monsterId: data.battle.monster.monster_id,
      monsterAttack: data.battle.monster.attack,
      monsterHealth: data.battle.monster.health,
      monsterType: GET_MONSTER(data.battle.monster.monster_id).monsterType,
    })

    setBattleEffects({
      enemyMarks: data.battle.battle_effects.enemy_marks,
      heroDmgReduction: data.battle.battle_effects.hero_dmg_reduction,
      nextHunterAttackBonus: data.battle.battle_effects.next_hunter_attack_bonus,
      nextHunterHealthBonus: data.battle.battle_effects.next_hunter_health_bonus,
      nextBruteAttackBonus: data.battle.battle_effects.next_brute_attack_bonus,
      nextBruteHealthBonus: data.battle.battle_effects.next_brute_health_bonus,
    })

    setHand(data.battle.hand.map((card, i) => CARD_DETAILS(card, i + 1)))
    setDeck(data.battle.deck)

    if (data.board && Object.keys(data.board).length > 0) {
      let board = Object.entries(data.board).reduce((acc, [key, creature]) => {
        acc[key] = {
          ...creature,
          cardId: creature.card_id,
        };
        return acc;
      }, {});

      setBoard(formatBoard(board))
    }

    setResettingState(false)
  }

  return (
    <BattleContext.Provider
      value={{
        actions: {
          startBattle,
          summonCreature,
          castSpell,
          endTurn,
        },

        utils: {
          creatureDeathEffect,
          getMonsterPosition,
          getCreaturePosition,
          fetchBattleState,
          resetBattleState,
          setBoard,
          getCardCost,
        },

        state: {
          pendingTx,
          values,
          hand,
          board,
          deck,
          battleEffects,
          resettingState,
        }
      }}
    >
      {children}
    </BattleContext.Provider>
  );
};