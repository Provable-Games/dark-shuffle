import { useSnackbar } from "notistack";
import React, { createContext, useContext, useEffect, useState } from "react";
import { isMobile } from 'react-device-detect';
import { getBattleState } from "../api/indexer";
import { applyCardEffect, requirementMet } from "../battle/cardUtils";
import { endOfTurnMonsterEffect } from "../battle/monsterAbility";
import { GET_MONSTER } from "../battle/monsterUtils";
import { summonEffect } from "../battle/summonUtils";
import { tags } from "../helpers/cards";
import { ADVENTURER_ID } from "../helpers/constants";
import { delay } from "../helpers/utilities";
import { AnimationContext } from "./animationHandler";
import { DojoContext } from "./dojoContext";
import { GameContext } from "./gameContext";

export const BattleContext = createContext()

export const BattleProvider = ({ children }) => {
  const dojo = useContext(DojoContext)
  const game = useContext(GameContext)
  const { gameEffects } = game.getState

  const animationHandler = useContext(AnimationContext)

  const { enqueueSnackbar } = useSnackbar()

  const [values, setValues] = useState({})
  const [updatedValues, setUpdatedValues] = useState()

  const [hand, setHand] = useState([])
  const [newHandCards, setNewHandCards] = useState([])

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

  useEffect(() => {
    if (values.monsterHealth < 1 && !endState) {
      submitBattleActions()
    }
  }, [values.monsterHealth])


  const resetBattleState = () => {
    setValues({})
    setBattleEffects()
    setHand([])
    setNewHandCards([])
    setDeck([])
    setBoard([])
    setActions([])
    setTurnEnded(false)
    setEndState()
    setRoundStats({})
    setPendingTx(false)
    setUpdatedValues()
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
    const battleResources = res.find(e => e.componentName === 'BattleResources')
    setUpdatedValues({ ...battleValues, ...battleResources })

    if (gameValues) {
      setEndState({ gameValues, leaderboard, gameEffects })
    }

    setPendingTx(false)
  }

  const endTurn = async () => {
    if (game.values.replay) {
      return
    }

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

  const startBattle = async (battle, battleResources) => {
    animationHandler.resetAnimationHandler()

    setValues({
      battleId: battle.battleId,
      round: battle.round,
      ...battle.hero,
      ...battle.monster,
      monsterType: GET_MONSTER(battle.monster.monsterId).monsterType
    })
    setBattleEffects({ ...battle.battleEffects })
    setHand(battleResources.hand.map((card, i) => game.utils.getCard(card, i + 1)))
    setDeck(battleResources.deck)
    setBoard(battleResources.board.map((creature, i) => ({
      ...game.utils.getCard(creature.cardIndex, i),
      attack: creature.attack,
      health: creature.health,
    })))

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

    setValues(prev => ({ ...prev, heroEnergy: prev.heroEnergy - cost }))
    const startValues = { attack: creature.attack, health: creature.health }

    summonEffect({
      creature, values, board, battleEffects, setBattleEffects, gameEffects,
      updateBoard, reduceMonsterAttack, increaseEnergy, damageMonster, setValues,
      damageHero, healHero, roundStats, setRoundStats
    })

    setBoard(prev => [...prev, { ...creature, id: (prev[prev.length - 1]?.id || 0) + 1, startValues }])
    setHand(prev => prev.filter(card => card.id !== creature.id))
    setActions(prev => [...prev, [0, creature.cardIndex]])
  }

  const castSpell = (spell) => {
    let cost = spell.cost;

    if (cost > values.heroEnergy) {
      return enqueueSnackbar('Not enough energy', { variant: 'warning' })
    }

    setValues(prev => ({ ...prev, heroEnergy: prev.heroEnergy - cost }))

    if (requirementMet(spell.effect.modifier.requirement, spell.cardType, board, values.monsterType, false)) {
      applyCardEffect({
        values, cardEffect: spell.effect, creature: spell, board, healHero,
        increaseEnergy, battleEffects, setBattleEffects,
        reduceMonsterAttack, damageMonster, updateBoard,
        onBoard: false
      })
    }

    if (spell.extraEffect?.modifier?._type !== 'None') {
      if (requirementMet(spell.extraEffect.modifier.requirement, spell.cardType, board, values.monsterType, false)) {
        applyCardEffect({
          values, cardEffect: spell.extraEffect, creature: spell, board, healHero,
          increaseEnergy, battleEffects, setBattleEffects,
          reduceMonsterAttack, damageMonster, updateBoard,
          onBoard: false
        })
      }
    }

    setHand(prev => prev.filter(card => card.id !== spell.id))
    setActions(prev => [...prev, [0, spell.cardIndex]])
  }

  const startNewTurn = () => {
    setValues({
      battleId: updatedValues.battleId,
      round: updatedValues.round,
      ...updatedValues.hero,
      ...updatedValues.monster,
      monsterType: GET_MONSTER(updatedValues.monster.monsterId).monsterType
    })

    if (isMobile) {
      setHand(updatedValues.hand.map((card, i) => game.utils.getCard(card, i + 1)))
    } else {
      setHand(updatedValues.hand.slice(0, hand.length).map((card, i) => game.utils.getCard(card, i + 1)))
      setNewHandCards(updatedValues.hand.slice(hand.length).map((card, i) => game.utils.getCard(card, hand.length + i + 1)))
    }

    setBoard(prev => prev.map(creature => ({ ...creature, attacked: false })))
    setDeck(updatedValues.deck)

    setActions([])
    setUpdatedValues()

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

  const updateBoard = (cardType, attack, health) => {
    const updatedBoard = board.map(creature => (creature.cardType === cardType || cardType === tags.ALL)
      ? { ...creature, attack: creature.attack + attack, health: creature.health + health }
      : creature
    )
    setBoard(updatedBoard)
  }

  const cleanBoard = () => {
    setBoard(prev => prev.map(creature => creature.health < 1 ? { ...creature, dead: true } : creature))
  }

  // MONSTER UTILS
  const damageMonster = (amount, cardType) => {
    amount += battleEffects.enemyMarks

    if (amount < 1) {
      return;
    }

    if (values.monsterId == 75 && cardType == tags.HUNTER) {
      amount -= 1;
    } else if (values.monsterId == 70 && cardType == tags.MAGICAL) {
      amount -= 1;
    } else if (values.monsterId == 65 && cardType == tags.BRUTE) {
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
    if (values.monsterId == 74 && creature.cardType == tags.HUNTER) {
      amount += 1;
    } else if (values.monsterId == 69 && creature.cardType == tags.MAGICAL) {
      amount += 1;
    } else if (values.monsterId == 64 && creature.cardType == tags.BRUTE) {
      amount += 1;
    }

    creature.health -= amount;
    updateBoardCreature(creature.id, { ...creature })
  }

  const creatureAttack = (creatureId) => {
    let creature = { ...board.find(creature => creature.id === creatureId) }

    if (creature.attackEffect?.modifier?._type !== 'None') {
      if (requirementMet(creature.attackEffect.modifier.requirement, creature.cardType, board, values.monsterType, true)) {
        applyCardEffect({
          values, cardEffect: creature.attackEffect, creature, board, healHero,
          increaseEnergy, battleEffects, setBattleEffects,
          reduceMonsterAttack, damageMonster, updateBoard,
          onBoard: true
        })
      }
    }

    damageMonster(creature.attack, creature.cardType)

    creature.attacked = true;
    setRoundStats(prev => ({ ...prev, creatureAttackCount: prev.creatureAttackCount + 1 }))

    damageCreature(creature, values.monsterAttack)
  }

  const creatureDeathEffect = (creature) => {
    if (creature.deathEffect?.modifier?._type !== 'None') {
      if (requirementMet(creature.deathEffect.modifier.requirement, creature.cardType, board, values.monsterType, true)) {
        applyCardEffect({
          values, cardEffect: creature.deathEffect, creature, board, healHero,
          increaseEnergy, battleEffects, setBattleEffects,
          reduceMonsterAttack, damageMonster, updateBoard,
          onBoard: true
        })
      }
    }
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

  const undoBattleActions = async () => {
    if (game.values.replay) {
      return
    }

    const battleId = values.battleId
    fetchBattleState(battleId, game.values.gameId)
  }

  const fetchBattleState = async (battleId, gameId) => {
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
      nextMagicalAttackBonus: data.battle.battle_effects.next_magical_attack_bonus,
      nextMagicalHealthBonus: data.battle.battle_effects.next_magical_health_bonus,
    })

    setHand(data.battleResources.hand.map((cardIndex, i) => game.utils.getCard(cardIndex, i + 1)))
    setDeck(data.battleResources.deck)
    setBoard(data.battleResources.board.map((creature, i) => ({
      ...game.utils.getCard(creature.card_index, i),
      attack: creature.attack,
      health: creature.health,
    })))

    setRoundStats({
      monsterStartHealth: data.battle.monster.health,
      creaturesPlayed: 0,
      creatureAttackCount: 0
    })

    setNewHandCards([])
    setActions([])
    setTurnEnded(false)
    setEndState()
    setPendingTx(false)
    setUpdatedValues()
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
          setHand,
          setNewHandCards,
          undoBattleActions,
        },

        state: {
          pendingTx: pendingTx || endState,
          values,
          hand,
          board,
          deck,
          battleEffects,
          newHandCards,
        }
      }}
    >
      {children}
    </BattleContext.Provider>
  );
};