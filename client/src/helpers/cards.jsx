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

export const CardSize = {
  big: { height: '330px', width: '252px' },
  large: { height: '275px', width: '210px' },
  medium: { height: '220px', width: '168px' },
  small: { height: '110px', width: '84px' }
}

export const buildEffectText = (cardType, effect) => {
  let text = ''
  let value = effect.modifier.value

  if (effect.bonus?.Some?.requirement === effect.modifier.requirement?.Some) {
    value += effect.bonus.Some.value
  }

  switch (effect.modifier._type) {
    case 'HeroHealth':
      text += `Hero gains +${value} health`
      break;
    case 'HeroEnergy':
      text += `Hero gains +${value} energy`
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
      text += `Deal ${value} extra damage`
      break;
    case 'NextAllyAttack':
      text += `Next ${cardType} gains +${value} attack when played`
      break;
    case 'NextAllyHealth':
      text += `Next ${cardType} gains +${value} health when played`
      break;
    case 'AllAttack':
      text += `All creatures gain +${value} attack`
      break;
    case 'AllHealth':
      text += `All creatures gain +${value} health`
      break;
    case 'AllyAttack':
      text += `Your ${cardType} creatures gain +${value} attack`
      break;
    case 'AllyHealth':
      text += `Your ${cardType} creatures gain +${value} health`
      break;
    case 'AllyStats':
      text += `Your ${cardType} creatures gain +${value} attack and +${value} health`
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

  if (effect.modifier?.requirement?.Some) {
    switch (effect.modifier.requirement.Some) {
      case 'EnemyWeak':
        text += ` if the enemy is ${getWeakType(cardType)}`
        break;
      case 'HasAlly':
        text += ` if you have another ${cardType}`
        break;
      case 'NoAlly':
        text += ` if you have no other ${cardType}`
        break;
      default:
        break;
    }
  }

  if (effect.bonus?.Some?.value > 0 && effect.bonus?.Some?.requirement !== effect.modifier.requirement.Some) {
    switch (effect.bonus.Some.requirement) {
      case 'EnemyWeak':
        text += `. Increase this to ${value + effect.bonus.Some.value} if the enemy is a ${getWeakType(cardType)}`
        break;
      case 'HasAlly':
        text += `. Increase this to ${value + effect.bonus.Some.value} if you have another ${cardType}`
        break;
      case 'NoAlly':
        text += `. Increase this to ${value + effect.bonus.Some.value} if you have no other ${cardType}`
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