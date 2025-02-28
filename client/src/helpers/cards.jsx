import { BruteIcon, HunterIcon, MagicalIcon } from "../assets/images/types/Icons";

export const fetch_card_image = (name) => {
  try {
    return new URL(`../assets/images/cards/${name.replace(" ", "_").toLowerCase()}.png`, import.meta.url).href
  } catch (ex) {
    return ""
  }
}

export const fetchBeastTypeImage = (type, color = '#ffffffe6') => {
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