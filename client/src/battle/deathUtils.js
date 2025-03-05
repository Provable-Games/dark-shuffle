import { tags } from "../helpers/cards";

export const deathEffect = ({
  creature, values, board, battleEffects, setBattleEffects,
  updateBoard, reduceMonsterAttack, healHero, damageMonster,
}) => {
  let updatedBattleEffects = {};

  if (creature.cardId === 3) {
    reduceMonsterAttack(2);

    if (values.monsterType === tags.BRUTE) {
      updateBoard(tags.MAGICAL, 2, 0);
    }
  }

  else if (creature.cardId === 10) {
    if (values.monsterType === tags.MAGICAL) {
      updatedBattleEffects.nextHunterAttackBonus = (battleEffects.nextHunterAttackBonus || 0) + 4;
    } else {
      updatedBattleEffects.nextHunterAttackBonus = (battleEffects.nextHunterAttackBonus || 0) + 2;
    }
  }

  else if (creature.cardId === 11) {
    updateBoard(tags.BRUTE, 2, 0);

    if (values.monsterType === tags.HUNTER) {
      reduceMonsterAttack(2);
    }
  }

  else if (creature.cardId === 15) {
    if (values.monsterType === tags.HUNTER) {
      updatedBattleEffects.nextBruteHealthBonus = battleEffects.nextBruteHealthBonus + 5;
    } else {
      updatedBattleEffects.nextBruteHealthBonus = battleEffects.nextBruteHealthBonus + 3;
    }
  }

  else if (creature.cardId === 16) {
    if (values.monsterType === tags.BRUTE) {
      reduceMonsterAttack(1);
    }

    updateBoard(tags.MAGICAL, 1, 0);
  }

  else if (creature.cardId === 19) {
    damageMonster(2, creature.creatureType);

    if (values.monsterType === tags.BRUTE) {
      reduceMonsterAttack(1);
    }
  }

  else if (creature.cardId === 25) {
    updatedBattleEffects.nextHunterAttackBonus = battleEffects.nextHunterAttackBonus + 2;

    if (values.monsterType === tags.MAGICAL) {
      updatedBattleEffects.nextHunterHealthBonus = battleEffects.nextHunterHealthBonus + 2;
    }
  }

  else if (creature.cardId === 26) {
    if (values.monsterType === tags.HUNTER) {
      healHero(2);
    }
  }

  else if (creature.cardId === 29) {
    updatedBattleEffects.nextBruteHealthBonus = battleEffects.nextBruteHealthBonus + 2;
  }

  else if (creature.cardId === 30) {
    updatedBattleEffects.nextBruteAttackBonus = battleEffects.nextBruteAttackBonus + 1;
  }

  else if (creature.cardId === 33) {
    if (values.monsterType === tags.BRUTE) {
      healHero(2);
    }

    updateBoard(tags.MAGICAL, 1, 0);
  }

  else if (creature.cardId === 38) {
    updatedBattleEffects.nextHunterAttackBonus = battleEffects.nextHunterAttackBonus + 1;

    if (values.monsterType === tags.MAGICAL) {
      updatedBattleEffects.nextHunterHealthBonus = battleEffects.nextHunterHealthBonus + 1;
    }
  }

  else if (creature.cardId === 41) {
    if (values.monsterType === tags.HUNTER) {
      updateBoard(tags.BRUTE, 1, 0);
    }
  }

  else if (creature.cardId === 45) {
    if (values.monsterType === tags.HUNTER) {
      if (board.bruteCount === 1) {
        healHero(2);
      } else {
        healHero(1);
      }
    }
  }

  else if (creature.cardId === 48) {
    if (board.magicalCount > 1) {
      healHero(2);
    }
  }

  else if (creature.cardId === 53) {
    if (values.monsterType === tags.MAGICAL) {
      updatedBattleEffects.nextHunterAttackBonus = battleEffects.nextHunterAttackBonus + 1;
    }
  }

  else if (creature.cardId === 56) {
    if (values.monsterType === tags.HUNTER) {
      updateBoard(tags.BRUTE, 1, 0);
    }
  }

  else if (creature.cardId === 60) {
    if (values.monsterType === tags.HUNTER) {
      healHero(2);
    }
  }

  else if (creature.cardId === 61) {
    if (values.monsterType === tags.BRUTE) {
      reduceMonsterAttack(1);
    }
  }

  else if (creature.cardId === 64) {
    if (values.monsterType === tags.BRUTE) {
      healHero(2);
    }
  }

  else if (creature.cardId === 68) {
    if (values.monsterType === tags.MAGICAL) {
      updatedBattleEffects.nextHunterAttackBonus = battleEffects.nextHunterAttackBonus + 1;
    }
  }

  else if (creature.cardId === 71) {
    if (values.monsterType === tags.HUNTER) {
      updateBoard(tags.BRUTE, 1, 0);
    }
  }

  else if (creature.cardId === 73) {
    if (values.monsterType === tags.HUNTER) {
      healHero(1);
    }
  }

  setBattleEffects(prev => ({ ...prev, ...updatedBattleEffects }));
}