import { tags, valueTypes } from "../helpers/cards";

export const applyCardEffect = ({
  values, cardEffect, creature, board, healHero,
  increaseEnergy, battleEffects, setBattleEffects,
  reduceMonsterAttack, damageMonster, updateBoard,
  onBoard, updatedBattleEffects
}) => {
  let cardType = creature.cardType;
  updatedBattleEffects = updatedBattleEffects || { ...battleEffects };

  let modifierValue = cardEffect.modifier.value_type === 'Fixed'
    ? cardEffect.modifier.value
    : cardEffect.modifier.value * allyCount(cardType, board);

  if (cardEffect.bonus.value && requirementMet(cardEffect.bonus.requirement, cardType, board, values.monsterType, onBoard)) {
    if (cardEffect.modifier.value_type === 'Fixed') {
      modifierValue += cardEffect.bonus.value;
    } else {
      modifierValue += cardEffect.bonus.value * allyCount(cardType, board);
    }
  }

  switch (cardEffect.modifier._type) {
    case 'HeroHealth':
      healHero(modifierValue);
      break;
    case 'HeroEnergy':
      increaseEnergy(modifierValue);
      break;
    case 'HeroDamageReduction':
      updatedBattleEffects.heroDmgReduction += modifierValue;
      break;
    case 'EnemyMarks':
      updatedBattleEffects.enemyMarks += modifierValue;
      break;
    case 'EnemyAttack':
      reduceMonsterAttack(modifierValue);
      break;
    case 'EnemyHealth':
      damageMonster(modifierValue, cardType);
      break;
    case 'NextAllyAttack':
      nextAllyAttack(cardType, modifierValue, updatedBattleEffects);
      break;
    case 'NextAllyHealth':
      nextAllyHealth(cardType, modifierValue, updatedBattleEffects);
      break;
    case 'AllAttack':
      updateBoard(tags.ALL, modifierValue, 0);
      break;
    case 'AllHealth':
      updateBoard(tags.ALL, 0, modifierValue);
      break;
    case 'AllyAttack':
      updateBoard(cardType, modifierValue, 0);
      break;
    case 'AllyHealth':
      updateBoard(cardType, 0, modifierValue);
      break;
    case 'AllyStats':
      updateBoard(cardType, modifierValue, modifierValue);
      break;
    case 'SelfAttack':
      creature.attack += modifierValue;
      break;
    case 'SelfHealth':
      creature.health += modifierValue;
      break;
  }

  setBattleEffects(prev => ({ ...prev, ...updatedBattleEffects }));
}

export function requirementMet(requirement, cardType, board, monsterType, onBoard) {
  let alliesRequired = onBoard ? 1 : 0;

  switch (requirement) {
    case 'None':
      return true;
    case 'EnemyWeak':
      return isEnemyWeak(cardType, monsterType);
    case 'HasAlly':
      return allyCount(cardType, board) > alliesRequired;
    case 'NoAlly':
      return allyCount(cardType, board) <= alliesRequired;
    default:
      return false;
  }
}

function isEnemyWeak(cardType, enemyType) {
  return (cardType === tags.HUNTER && enemyType === tags.MAGICAL) ||
    (cardType === tags.BRUTE && enemyType === tags.HUNTER) ||
    (cardType === tags.MAGICAL && enemyType === tags.BRUTE);
}

function allyCount(cardType, board) {
  switch (cardType) {
    case tags.HUNTER:
      return board.filter(creature => creature.cardType === tags.HUNTER).length;
    case tags.BRUTE:
      return board.filter(creature => creature.cardType === tags.BRUTE).length;
    case tags.MAGICAL:
      return board.filter(creature => creature.cardType === tags.MAGICAL).length;
    default:
      return 0;
  }
}

function nextAllyAttack(cardType, modifierValue, updatedBattleEffects) {
  if (cardType === tags.HUNTER) {
    updatedBattleEffects.nextHunterAttackBonus += modifierValue;
  } else if (cardType === tags.BRUTE) {
    updatedBattleEffects.nextBruteAttackBonus += modifierValue;
  } else if (cardType === tags.MAGICAL) {
    updatedBattleEffects.nextMagicalAttackBonus += modifierValue;
  }
}

function nextAllyHealth(cardType, modifierValue, updatedBattleEffects) {
  if (cardType === tags.HUNTER) {
    updatedBattleEffects.nextHunterHealthBonus += modifierValue;
  } else if (cardType === tags.BRUTE) {
    updatedBattleEffects.nextBruteHealthBonus += modifierValue;
  } else if (cardType === tags.MAGICAL) {
    updatedBattleEffects.nextMagicalHealthBonus += modifierValue;
  }
}