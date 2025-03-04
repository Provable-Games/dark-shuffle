import { tags } from "../helpers/cards";

export const summonEffect = ({
  creature, values, board, battleEffects, setBattleEffects, gameEffects,
  updateBoard, reduceMonsterAttack, increaseEnergy, damageMonster, setValues,
  damageHero, healHero, roundStats, setRoundStats
}) => {
  let updatedBattleEffects = {};

  let magicalCount = board.filter(creature => creature.creatureType === tags.MAGICAL).length
  let bruteCount = board.filter(creature => creature.creatureType === tags.BRUTE).length
  let hunterCount = board.filter(creature => creature.creatureType === tags.HUNTER).length

  if (roundStats.creaturesPlayed === 0) {
    creature.attack += gameEffects.firstAttack ?? 0;
    creature.health += gameEffects.firstHealth ?? 0;
  }

  if (gameEffects.playCreatureHeal > 0) {
    healHero(gameEffects.playCreatureHeal);
  }

  creature.attack += gameEffects.allAttack ?? 0;

  if (creature.creatureType === tags.HUNTER) {
    creature.attack += gameEffects.hunterAttack ?? 0;
    creature.health += gameEffects.hunterHealth ?? 0;

    creature.attack += battleEffects.nextHunterAttackBonus;
    creature.health += battleEffects.nextHunterHealthBonus;
    updatedBattleEffects.nextHunterAttackBonus = 0;
    updatedBattleEffects.nextHunterHealthBonus = 0;

    if (values.monsterId == 73) {
      setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + 1 }))
    } else if (values.monsterId == 72) {
      setValues(prev => ({ ...prev, monsterHealth: prev.monsterHealth + 2 }))
    }
  } else if (creature.creatureType === tags.BRUTE) {
    creature.health += gameEffects.bruteHealth ?? 0;
    creature.attack += gameEffects.bruteAttack ?? 0;

    creature.health += battleEffects.nextBruteHealthBonus;
    creature.attack += battleEffects.nextBruteAttackBonus;
    updatedBattleEffects.nextBruteHealthBonus = 0;
    updatedBattleEffects.nextBruteAttackBonus = 0;

    if (values.monsterId == 63) {
      setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + 1 }))
    } else if (values.monsterId == 62) {
      setValues(prev => ({ ...prev, monsterHealth: prev.monsterHealth + 2 }))
    }
  } else if (creature.creatureType === tags.MAGICAL) {
    creature.health += gameEffects.magicalHealth ?? 0;
    creature.attack += gameEffects.magicalAttack ?? 0;

    if (values.monsterId == 68) {
      setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + 1 }))
    } else if (values.monsterId == 67) {
      setValues(prev => ({ ...prev, monsterHealth: prev.monsterHealth + 2 }))
    }
  }

  if (creature.cardId === 1) {
    if (magicalCount === 0) {
      reduceMonsterAttack(1)
    } else {
      updateBoard(tags.MAGICAL, 2, 0)
    }
  }

  else if (creature.cardId === 4) {
    updateBoard(tags.ALL, 2, 0)

    if (values.monsterType === tags.BRUTE) {
      damageMonster(3, creature.creatureType);
    }
  }

  else if (creature.cardId === 7) {
    if (values.monsterType === tags.MAGICAL) {
      updatedBattleEffects.enemyMarks = battleEffects.enemyMarks + 3;
    } else {
      updatedBattleEffects.enemyMarks = battleEffects.enemyMarks + 2;
    }
  }

  else if (creature.cardId === 9) {
    if (values.monsterType === tags.MAGICAL) {
      damageMonster(4, creature.creatureType);
    } else {
      damageMonster(2, creature.creatureType);
    }
  }

  else if (creature.cardId === 12) {
    updatedBattleEffects.heroDmgReduction = battleEffects.heroDmgReduction + 1;
  }

  else if (creature.cardId === 14) {
    if (bruteCount > 0) {
      creature.health += 2;
    }
  }

  else if (creature.cardId === 17) {
    if (values.monsterType === tags.BRUTE) {
      creature.attack += 1;
    }
    if (magicalCount > 0) {
      creature.attack += 1;
    }
  }

  else if (creature.cardId === 18) {
    if (magicalCount > 0) {
      increaseEnergy(1);
      healHero(2);
    }
  }

  else if (creature.cardId === 22) {
    if (hunterCount === 0) {
      creature.attack += 2;
    }
  }

  else if (creature.cardId === 24) {
    if (values.monsterType === tags.MAGICAL) {
      updatedBattleEffects.enemyMarks = battleEffects.enemyMarks + 2;
    } else {
      updatedBattleEffects.enemyMarks = battleEffects.enemyMarks + 1;
    }
  }

  else if (creature.cardId === 31) {
    if (values.monsterType === tags.BRUTE) {
      reduceMonsterAttack(1);
      updateBoard(tags.MAGICAL, 0, 1);
    }
  }

  else if (creature.cardId === 34) {
    updateBoard(tags.MAGICAL, 1, 0);
    if (magicalCount >= 2) {
      increaseEnergy(1);
    }
  }

  else if (creature.cardId === 36) {
    updatedBattleEffects.enemyMarks = battleEffects.enemyMarks + 1;
  }

  else if (creature.cardId === 39) {
    if (hunterCount > 0) {
      creature.attack += 1;
    }
    if (values.monsterType === tags.MAGICAL) {
      updateBoard(tags.HUNTER, 1, 0);
    }
  }

  else if (creature.cardId === 42) {
    if (bruteCount > 0) {
      creature.attack += 1;
    }
    if (values.monsterType === tags.HUNTER) {
      creature.health += 1;
    }
  }

  else if (creature.cardId === 44) {
    if (bruteCount > 0) {
      creature.attack += 1;
    }
    if (values.monsterType === tags.HUNTER) {
      reduceMonsterAttack(1);
    }
  }

  else if (creature.cardId === 47) {
    if (values.monsterType === tags.BRUTE) {
      reduceMonsterAttack(1);
    }
  }

  else if (creature.cardId === 49) {
    updateBoard(tags.MAGICAL, 1, 0);
  }

  else if (creature.cardId === 51) {
    if (values.monsterType === tags.MAGICAL) {
      damageMonster(1, creature.creatureType);
    }
  }

  else if (creature.cardId === 54) {
    if (values.monsterType === tags.MAGICAL) {
      updatedBattleEffects.enemyMarks = battleEffects.enemyMarks + 1;
    }
  }

  else if (creature.cardId === 58) {
    if (bruteCount > 0) {
      creature.health += 1;
    }
  }

  else if (creature.cardId === 59) {
    if (values.monsterType === tags.HUNTER) {
      reduceMonsterAttack(1);
    }
  }

  else if (creature.cardId === 63) {
    if (values.monsterType === tags.BRUTE) {
      creature.attack += 2;
    }
  }

  else if (creature.cardId === 66) {
    if (values.monsterType === tags.MAGICAL) {
      damageMonster(1, creature.creatureType);
    }
  }

  else if (creature.cardId === 70) {
    if (hunterCount > 0) {
      creature.attack += 1;
    }
  }

  else if (creature.cardId === 72) {
    if (values.monsterType === tags.HUNTER) {
      damageMonster(1, creature.creatureType);
    }
  }

  else if (creature.cardId === 74) {
    if (values.monsterType === tags.HUNTER) {
      reduceMonsterAttack(1);
    }
  }

  if (values.monsterId === 55) {
    if (creature.health > creature.attack) {
      damageHero(2);
    }
  }

  setRoundStats(prev => ({ ...prev, creaturesPlayed: prev.creaturesPlayed + 1 }));
  setBattleEffects(prev => ({ ...prev, ...updatedBattleEffects }));
}