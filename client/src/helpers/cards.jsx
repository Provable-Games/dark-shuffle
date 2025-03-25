import { BruteIcon, HunterIcon, MagicalIcon } from "../assets/images/types/Icons";

export const fetch_card_image = (name) => {
  try {
    return new URL(`../assets/images/cards/${name.replace(" ", "_").toLowerCase()}.png`, import.meta.url).href
  } catch (ex) {
    return ""
  }
}

export const fetchCardTypeImage = (type, color = '#ffffffe6') => {
  if (type === tags.MAGICAL) return <MagicalIcon color={color} />
  if (type === tags.HUNTER) return <HunterIcon color={color} />
  if (type === tags.BRUTE) return <BruteIcon color={color} />
}

export const tierColors = {
  common: '#8B7D6B',
  uncommon: '#DDEAE0',
  rare: '#3B82F6',
  epic: '#A855F7',
  legendary: '#F97316',
}

export const buildEffectText = (cardType, effect, effectType) => {
  let isSpell = effectType === 'spell' || effectType === 'spell_extra'

  let value = effect.modifier.value
  if (effect.bonus.requirement === effect.modifier.requirement) {
    value += effect.bonus.value
  }

  let text = ''
  switch (effect.modifier._type) {
    case 'HeroHealth':
      text += `Hero gains ${value} health`
      break;
    case 'HeroEnergy':
      text += `Hero gains ${value} energy`
      break;
    case 'HeroDamageReduction':
      text += `Hero gains +${value} armor`
      break;
    case 'EnemyMarks':
      text += `Marks the enemy to take ${value} additional damage`
      break;
    case 'EnemyAttack':
      text += `Reduce enemy attack by ${value}`
      break;
    case 'EnemyHealth':
      text += `Deal ${value} ${effectType === 'attack' ? 'extra' : ''} damage`
      break;
    case 'NextAllyAttack':
      text += `Next ${cardType} gains +${value} attack when played`
      break;
    case 'NextAllyHealth':
      text += `Next ${cardType} gains +${value} health when played`
      break;
    case 'AllAttack':
      text += `All ${isSpell ? '' : 'other '}creatures gain +${value} attack`
      break;
    case 'AllHealth':
      text += `All ${isSpell ? '' : 'other '}creatures gain +${value} health`
      break;
    case 'AllyAttack':
      text += `Your ${isSpell ? '' : 'other '}${cardType} creatures gain +${value} attack`
      break;
    case 'AllyHealth':
      text += `Your ${isSpell ? '' : 'other '}${cardType} creatures gain +${value} health`
      break;
    case 'AllyStats':
      text += `Your ${isSpell ? '' : 'other '}${cardType} creatures gain +${value}/+${value}`
      break;
    case 'SelfAttack':
      text += `Gains +${value} attack`
      break;
    case 'SelfHealth':
      text += `Gains +${value} health`
      break;
    default:
      break;
  }

  if (effect.modifier.value_type === 'PerAlly') {
    text += ` for each ${cardType} ally`
  }

  if (effect.modifier?.requirement !== 'None') {
    switch (effect.modifier.requirement) {
      case 'EnemyWeak':
        text += ` if the enemy is a ${getWeakType(cardType)}`
        break;
      case 'HasAlly':
        text += ` if you have ${isSpell ? 'a' : 'another'} ${cardType}`
        break;
      case 'NoAlly':
        text += ` if you have no ${isSpell ? '' : 'other '}${cardType}`
        break;
      default:
        break;
    }
  }

  if (effect.bonus.value > 0 && effect.bonus.requirement !== effect.modifier.requirement) {
    switch (effect.bonus.requirement) {
      case 'EnemyWeak':
        text += `. Increase this to ${value + effect.bonus.value} if the enemy is a ${getWeakType(cardType)}`
        break;
      case 'HasAlly':
        text += `. Increase this to ${value + effect.bonus.value} if you have ${isSpell ? 'a' : 'another'} ${cardType}`
        break;
      case 'NoAlly':
        text += `. Increase this to ${value + effect.bonus.value} if you have no ${isSpell ? '' : 'other '}${cardType}`
        break;
      default:
        break;
    }
  }

  return text
}

export const getWeakType = (cardType) => {
  if (cardType === tags.MAGICAL) return tags.BRUTE
  if (cardType === tags.HUNTER) return tags.MAGICAL
  if (cardType === tags.BRUTE) return tags.HUNTER
}

export const formatCardEffect = (cardEffect) => {
  if (!cardEffect || !cardEffect.modifier) return {};

  // Format the modifier
  const formattedModifier = {
    _type: modifiers[cardEffect.modifier._type],
    value: cardEffect.modifier.value,
    value_type: valueTypes[cardEffect.modifier.value_type],
    requirement: requirements[cardEffect.modifier.requirement]
  };

  const formattedBonus = {
    value: cardEffect.bonus.value,
    requirement: requirements[cardEffect.bonus.requirement]
  };

  return {
    modifier: formattedModifier,
    bonus: formattedBonus
  };
}

export const types = {
  CREATURE: 'Creature',
  SPELL: 'Spell'
}

export const tags = {
  MAGICAL: 'Magical',
  HUNTER: 'Hunter',
  BRUTE: 'Brute',
  ALL: 'All',
  SPELL: 'Spell'
}

export const modifiers = {
  0: 'None',
  1: 'HeroHealth',
  2: 'HeroEnergy',
  3: 'HeroDamageReduction',
  4: 'EnemyMarks',
  5: 'EnemyAttack',
  6: 'EnemyHealth',
  7: 'NextAllyAttack',
  8: 'NextAllyHealth',
  9: 'AllAttack',
  10: 'AllHealth',
  11: 'AllyAttack',
  12: 'AllyHealth',
  13: 'AllyStats',
  14: 'SelfAttack',
  15: 'SelfHealth'
}

export const valueTypes = {
  0: 'None',
  1: 'Fixed',
  2: 'PerAlly'
}

export const requirements = {
  0: 'None',
  1: 'EnemyWeak',
  2: 'HasAlly',
  3: 'NoAlly'
}

export const rarities = {
  0: 'None',
  1: 'Common',
  2: 'Uncommon',
  3: 'Rare',
  4: 'Epic',
  5: 'Legendary'
}

export const cardTypes = {
  0: 'None',
  1: 'Hunter',
  2: 'Brute',
  3: 'Magical'
}

export const CardSize = {
  big: { height: '330px', width: '252px' },
  large: { height: '275px', width: '210px' },
  medium: { height: '220px', width: '168px' },
  small: { height: '110px', width: '84px' }
}