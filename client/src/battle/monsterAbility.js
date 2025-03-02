export const endOfTurnMonsterEffect = ({
  setValues, values, damageHero, hand, roundStats, board
}) => {
  if (values.monsterId === 2) {
    damageHero(hand.length)
  }

  else if (values.monsterId === 14) {
    setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + hand.length }))
  }

  else if (values.monsterId === 15) {
    setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + roundStats.creatureAttackCount }))
  }

  else if (values.monsterId === 30 && values.monsterHealth >= roundStats.monsterStartHealth) {
    damageHero(3)
  }

  else if (values.monsterId === 57 && board.length > 0) {
    const strongestCreature = board.reduce((max, creature) => creature.attack > max.attack ? creature : max, board[0])

    if (strongestCreature.attack > values.monsterAttack) {
      setValues(prev => ({ ...prev, monsterHealth: prev.monsterHealth + 2 }))
    }
  }

  else if (values.monsterId === 58 && board.length > 0) {
    const strongestCreature = board.reduce((max, creature) => creature.attack > max.attack ? creature : max, board[0])

    if (strongestCreature.attack > values.monsterAttack) {
      setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + 1 }))
    }
  }

  else if (values.monsterId === 59 && values.monsterHealth >= roundStats.monsterStartHealth) {
    setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + 2 }))
  }
}
