import { tags } from "../helpers/cards";
import { applyCardEffect, requirementMet } from "./cardUtils";

export const summonEffect = ({
  creature, values, board, battleEffects, setBattleEffects, gameEffects,
  updateBoard, reduceMonsterAttack, increaseEnergy, damageMonster, setValues,
  damageHero, healHero, roundStats, setRoundStats,
}) => {
  let updatedBattleEffects = { ...battleEffects };

  if (roundStats.creaturesPlayed === 0) {
    creature.attack += gameEffects.firstAttack ?? 0;
    creature.health += gameEffects.firstHealth ?? 0;
  }

  if (gameEffects.playCreatureHeal > 0) {
    healHero(gameEffects.playCreatureHeal);
  }

  creature.attack += gameEffects.allAttack ?? 0;

  if (creature.cardType === tags.HUNTER) {
    creature.attack += gameEffects.hunterAttack ?? 0 + battleEffects.nextHunterAttackBonus;
    creature.health += gameEffects.hunterHealth ?? 0 + battleEffects.nextHunterHealthBonus;

    updatedBattleEffects.nextHunterAttackBonus = 0;
    updatedBattleEffects.nextHunterHealthBonus = 0;

    if (values.monsterId == 73) {
      setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + 1 }))
    } else if (values.monsterId == 72) {
      setValues(prev => ({ ...prev, monsterHealth: prev.monsterHealth + 2 }))
    }
  } else if (creature.cardType === tags.BRUTE) {
    creature.attack += gameEffects.bruteAttack ?? 0 + battleEffects.nextBruteAttackBonus;
    creature.health += gameEffects.bruteHealth ?? 0 + battleEffects.nextBruteHealthBonus;

    updatedBattleEffects.nextBruteHealthBonus = 0;
    updatedBattleEffects.nextBruteAttackBonus = 0;

    if (values.monsterId == 63) {
      setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + 1 }))
    } else if (values.monsterId == 62) {
      setValues(prev => ({ ...prev, monsterHealth: prev.monsterHealth + 2 }))
    }
  } else if (creature.cardType === tags.MAGICAL) {
    creature.attack += gameEffects.magicalAttack ?? 0 + battleEffects.nextMagicalAttackBonus;
    creature.health += gameEffects.magicalHealth ?? 0 + battleEffects.nextMagicalHealthBonus;

    updatedBattleEffects.nextMagicalHealthBonus = 0;
    updatedBattleEffects.nextMagicalAttackBonus = 0;

    if (values.monsterId == 68) {
      setValues(prev => ({ ...prev, monsterAttack: prev.monsterAttack + 1 }))
    } else if (values.monsterId == 67) {
      setValues(prev => ({ ...prev, monsterHealth: prev.monsterHealth + 2 }))
    }
  }

  if (creature.playEffect?.modifier?._type !== 'None') {
    if (requirementMet(creature.playEffect.modifier.requirement, creature.cardType, board, values.monsterType, false)) {
      applyCardEffect({
        values, cardEffect: creature.playEffect, creature, board, healHero,
        increaseEnergy, battleEffects, setBattleEffects, updatedBattleEffects,
        reduceMonsterAttack, damageMonster, updateBoard,
        onBoard: false
      })
    }
  }

  if (values.monsterId === 55) {
    if (creature.health > creature.attack) {
      damageHero(2);
    }
  }

  setRoundStats(prev => ({ ...prev, creaturesPlayed: prev.creaturesPlayed + 1 }));
}