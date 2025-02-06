import { tags } from "../helpers/cards";

export const spellEffect = ({
  spell, values, board, healHero, updateBoard, reduceMonsterAttack,
  increaseEnergy, damageMonster, battleEffects, setBattleEffects
}) => {
  let updatedBattleEffects = {};

  let bruteCount = board.filter(creature => creature.creatureType === tags.BRUTE).length

  if (spell.cardId === 76) {
    increaseEnergy(3);
  }

  else if (spell.cardId === 77) {
    if (values.monsterType === tags.MAGICAL) {
      damageMonster(8, 'Spell');
    } else {
      damageMonster(4, 'Spell');
    }
  }

  else if (spell.cardId === 78) {
    updatedBattleEffects.enemyMarks = battleEffects.enemyMarks + 2;
  }

  else if (spell.cardId === 79) {
    reduceMonsterAttack(1);
  }

  else if (spell.cardId === 80) {
    updateBoard(tags.BRUTE, 2, 0);
  }

  else if (spell.cardId === 81) {
    updateBoard(tags.ALL, 2, 0);
  }

  else if (spell.cardId === 82) {
    healHero(bruteCount);
  }

  else if (spell.cardId === 83) {
    updateBoard(tags.HUNTER, 3, 3);
  }

  else if (spell.cardId === 84) {
    damageMonster(4, 'Spell');
    healHero(4);
  }

  else if (spell.cardId === 85) {
    damageMonster(4, 'Spell');
  }

  else if (spell.cardId === 86) {
    healHero(5);
  }

  else if (spell.cardId === 87) {
    updateBoard(tags.ALL, 0, 2);
  }

  else if (spell.cardId === 88) {
    updateBoard(tags.BRUTE, 1, 1);
  }

  else if (spell.cardId === 89) {
    updateBoard(tags.MAGICAL, 1, 1);
  }

  else if (spell.cardId === 90) {
    updateBoard(tags.HUNTER, 1, 1);
  }

  setBattleEffects(prev => ({ ...prev, ...updatedBattleEffects }));
}