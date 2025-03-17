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

export const fetchBoardCreatures = (data) => {
  return data.creatures.map(card => ({
    ...CARD_DETAILS(card.cardId, card.creature_id),
  }))
}

export const fetchCardList = () => {
  return Array(90).fill(0).map((_, i) => {
    return CARD_DETAILS(i + 1, i + 1)
  })
}

export const formatBoard = (data) => {
  function formatCreature(creature, i) {
    if (creature.cardId === 0) return;

    return {
      ...CARD_DETAILS(creature.cardId, i),
      attack: creature.attack,
      health: creature.health
    }
  }

  return [
    formatCreature(data['creature1'], 0),
    formatCreature(data['creature2'], 1),
    formatCreature(data['creature3'], 2),
    formatCreature(data['creature4'], 3),
    formatCreature(data['creature5'], 4),
    formatCreature(data['creature6'], 5)
  ].filter(Boolean)
}

export const CARD_DETAILS = (cardId, id) => {
  switch (cardId) {
    case 1:
      return {
        id,
        cardId: 1,
        name: 'Warlock',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.MAGICAL,
        cost: 3,
        attack: 3,
        health: 4,
        text: "When Played: Magical allies gains +2 attack. If no other Magical ally is in play, reduce the enemy's attack by 1"
      };

    case 2:
      return {
        id,
        cardId: 2,
        name: 'Typhon',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.MAGICAL,
        cost: 5,
        attack: 5,
        health: 5,
        text: "On Attack: Heals the hero by 2 if the enemy is a Brute and gains +1 health for every Magical ally in play"
      };

    case 3:
      return {
        id,
        cardId: 3,
        name: 'Jiangshi',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.MAGICAL,
        cost: 3,
        attack: 5,
        health: 4,
        text: "On Death: Reduce the enemy's attack by 1. All other Magical allies gain +2 attack if the enemy is a Brute"
      };

    case 4:
      return {
        id,
        cardId: 4,
        name: 'Anansi',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.MAGICAL,
        cost: 4,
        attack: 4,
        health: 5,
        text: "When Played: Grants all allies +2 attack. If the enemy is a Brute, inflict 3 damage immediately"
      };

    case 5:
      return {
        id,
        cardId: 5,
        name: 'Basilisk',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.MAGICAL,
        cost: 1,
        attack: 3,
        health: 3,
        text: "On Attack: Deals an additional 2 damage if another Magical ally is in play."
      };

    case 6:
      return {
        id,
        cardId: 6,
        name: 'Griffin',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.HUNTER,
        cost: 4,
        attack: 5,
        health: 4,
        text: "On Attack: Deals 5 extra damage if the enemy is Magical"
      };

    case 7:
      return {
        id,
        cardId: 7,
        name: 'Manticore',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.HUNTER,
        cost: 4,
        attack: 4,
        health: 5,
        text: "When Played: Marks the enemy to take 2 additional damage. If the enemy is Magical, increase this to 3"
      };

    case 8:
      return {
        id,
        cardId: 8,
        name: 'Phoenix',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.HUNTER,
        cost: 1,
        attack: 3,
        health: 2,
        text: "On Attack: Gains +1 attack for each Hunter ally in play"
      };

    case 9:
      return {
        id,
        cardId: 9,
        name: 'Dragon',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.HUNTER,
        cost: 2,
        attack: 4,
        health: 3,
        text: "When Played: Deals 4 damage if the enemy is Magical. Otherwise, deals 2 damage"
      };

    case 10:
      return {
        id,
        cardId: 10,
        name: 'Minotaur',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.HUNTER,
        cost: 3,
        attack: 5,
        health: 4,
        text: "On Death: Grants +2 attack to the next Hunter played. If the enemy is Magical, the bonus increases to +4 attack"
      };

    case 11:
      return {
        id,
        cardId: 11,
        name: 'Kraken',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.BRUTE,
        cost: 2,
        attack: 3,
        health: 3,
        text: "On Death: Grants all Brute allies +2 attack. If the enemy is a Hunter, it loses 2 attack"
      };

    case 12:
      return {
        id,
        cardId: 12,
        name: 'Colossus',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.BRUTE,
        cost: 5,
        attack: 5,
        health: 7,
        text: "When Played: Reduces all damage to the hero by 1 for the rest of the battle"
      };

    case 13:
      return {
        id,
        cardId: 13,
        name: 'Balrog',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.BRUTE,
        cost: 3,
        attack: 4,
        health: 6,
        text: "On Attack: Deals an extra 2 damage if the enemy is a Hunter and gains +1 attack if another Brute is in play"
      };

    case 14:
      return {
        id,
        cardId: 14,
        name: 'Leviathan',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.BRUTE,
        cost: 1,
        attack: 4,
        health: 3,
        text: "When Played: Gains +2 health if another Brute ally is in play."
      };

    case 15:
      return {
        id,
        cardId: 15,
        name: 'Tarrasque',
        cardType: types.CREATURE,
        cardTier: 1,
        creatureType: tags.BRUTE,
        cost: 1,
        attack: 3,
        health: 3,
        text: "On Death: Grants +3 health to the next Brute played. If the enemy is a Hunter, grants +5 health instead"
      };

    case 16:
      return {
        id,
        cardId: 16,
        name: 'Gorgon',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.MAGICAL,
        cost: 2,
        attack: 3,
        health: 3,
        text: "On Death: Reduces the enemy's attack by 1 if the enemy is a Brute. All other Magical allies gain +1 attack"
      };

    case 17:
      return {
        id,
        cardId: 17,
        name: 'Kitsune',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.MAGICAL,
        cost: 2,
        attack: 3,
        health: 3,
        text: "When Played: Gain +1 attack if the enemy is a Brute. Gain +1 attack if a Magical ally is in play"
      };

    case 18:
      return {
        id,
        cardId: 18,
        name: 'Lich',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.MAGICAL,
        cost: 4,
        attack: 3,
        health: 4,
        text: "When Played: Increase the hero's energy by 1 and grants +2 health to the hero if another Magical ally is in play"
      };

    case 19:
      return {
        id,
        cardId: 19,
        name: 'Chimera',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.MAGICAL,
        cost: 3,
        attack: 3,
        health: 4,
        text: "On Death: Deals 2 damage to the enemy. If the enemy is a Brute, also reduce their attack by 1"
      };

    case 20:
      return {
        id,
        cardId: 20,
        name: 'Wendigo',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.MAGICAL,
        cost: 2,
        attack: 2,
        health: 3,
        text: "On Attack: Reduces the enemy's attack by 1 if the enemy is a Brute"
      };

    case 21:
      return {
        id,
        cardId: 21,
        name: 'Qilin',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.HUNTER,
        cost: 1,
        attack: 3,
        health: 2,
        text: "On Attack: Deals 1 extra damage if the enemy is Magical. Gains +1 health if it survives combat"
      };

    case 22:
      return {
        id,
        cardId: 22,
        name: 'Ammit',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.HUNTER,
        cost: 3,
        attack: 5,
        health: 2,
        text: "When Played: Gains +2 attack if there are no other Hunter allies in play"
      };

    case 23:
      return {
        id,
        cardId: 23,
        name: 'Nue',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.HUNTER,
        cost: 2,
        attack: 4,
        health: 2,
        text: "On Attack: Gains +1 attack if the enemy is Magical. Deals 1 extra damage if another Hunter ally is in play"
      };

    case 24:
      return {
        id,
        cardId: 24,
        name: 'Skinwalker',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.HUNTER,
        cost: 4,
        attack: 4,
        health: 3,
        text: "When Played: Marks the enemy to take 1 additional damage. If the enemy is Magical, increase the damage to 2"
      };

    case 25:
      return {
        id,
        cardId: 25,
        name: 'Chupacabra',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.HUNTER,
        cost: 2,
        attack: 2,
        health: 3,
        text: "On Death: Grants +2 attack to the next Hunter played. Also grants +2 health if the enemy is Magical"
      };

    case 26:
      return {
        id,
        cardId: 26,
        name: 'Titan',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.BRUTE,
        cost: 2,
        attack: 2,
        health: 5,
        text: "On Death: Restores 2 health to the hero if the enemy is a Hunter"
      };

    case 27:
      return {
        id,
        cardId: 27,
        name: 'Nephilim',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.BRUTE,
        cost: 3,
        attack: 4,
        health: 4,
        text: "Nephilim takes 1 less damage from all sources. If another Brute ally is in play, increase this to 2"
      };

    case 28:
      return {
        id,
        cardId: 28,
        name: 'Behemoth',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.BRUTE,
        cost: 3,
        attack: 4,
        health: 3,
        text: "On Attack: Gains +2 health if the enemy is a Hunter"
      };

    case 29:
      return {
        id,
        cardId: 29,
        name: 'Hydra',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.BRUTE,
        cost: 1,
        attack: 3,
        health: 2,
        text: "On Death: Grants +2 health to the next Brute played"
      };

    case 30:
      return {
        id,
        cardId: 30,
        name: 'Juggernaut',
        cardType: types.CREATURE,
        cardTier: 2,
        creatureType: tags.BRUTE,
        cost: 3,
        attack: 3,
        health: 4,
        text: "On Death: Grants +1 attack to the next Brute played"
      };

    case 31:
      return {
        id,
        cardId: 31,
        name: 'Rakshasa',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.MAGICAL,
        cost: 4,
        attack: 4,
        health: 4,
        text: "When Played: If the enemy is a Brute, reduce the enemy's attack by 1 and grant +1 health to other Magical allies"
      };

    case 32:
      return {
        id,
        cardId: 32,
        name: 'Werewolf',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.MAGICAL,
        cost: 2,
        attack: 3,
        health: 3,
        text: "On Attack: Deals 1 extra damage if another Magical ally is in play. Gains +1 health if it survives combat"
      };

    case 33:
      return {
        id,
        cardId: 33,
        name: 'Banshee',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.MAGICAL,
        cost: 4,
        attack: 3,
        health: 3,
        text: "On Death: Grants +2 health to the hero if the enemy is a Brute. All other Magical allies gain +1 attack"
      };

    case 34:
      return {
        id,
        cardId: 34,
        name: 'Draugr',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.MAGICAL,
        cost: 1,
        attack: 2,
        health: 2,
        text: "When Played: Magical allies gain +1 attack. If there are two or more other Magical allies, gain 1 energy"
      };

    case 35:
      return {
        id,
        cardId: 35,
        name: 'Vampire',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.MAGICAL,
        cost: 4,
        attack: 4,
        health: 3,
        text: "On Attack: Deals 1 extra damage to the enemy if it's a Brute. If Vampire is the only Magical ally in play, it gains +1 attack"
      };

    case 36:
      return {
        id,
        cardId: 36,
        name: 'Weretiger',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.HUNTER,
        cost: 5,
        attack: 6,
        health: 3,
        text: "When Played: Marks the enemy, causing it to take 1 additional damage."
      };

    case 37:
      return {
        id,
        cardId: 37,
        name: 'Wyvern',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.HUNTER,
        cost: 1,
        attack: 3,
        health: 2,
        text: "On Attack: Deals 1 extra damage if there is another Hunter ally in play and gains +1 attack if enemy is Magical"
      };

    case 38:
      return {
        id,
        cardId: 38,
        name: 'Roc',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.HUNTER,
        cost: 4,
        attack: 5,
        health: 4,
        text: "On Death: Grants +1 attack to the next Hunter played. Also gains +1 health if the enemy is Magical"
      };

    case 39:
      return {
        id,
        cardId: 39,
        name: 'Harpy',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.HUNTER,
        cost: 2,
        attack: 3,
        health: 3,
        text: "When Played: Gain +1 attack if another Hunter ally is in play. If the enemy is Magical, Hunter allies gain +1 attack"
      };

    case 40:
      return {
        id,
        cardId: 40,
        name: 'Pegasus',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.HUNTER,
        cost: 3,
        attack: 4,
        health: 3,
        text: "On Attack: Deals 1 extra damage if the enemy is Magical"
      };

    case 41:
      return {
        id,
        cardId: 41,
        name: 'Oni',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.BRUTE,
        cost: 3,
        attack: 3,
        health: 5,
        text: "On Death: Grants +1 attack to all Brute allies if the enemy is a Hunter"
      };

    case 42:
      return {
        id,
        cardId: 42,
        name: 'Jotunn',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.BRUTE,
        cost: 2,
        attack: 3,
        health: 3,
        text: "When Played: Gains +1 attack if another Brute ally is in play. If the enemy is a Hunter, it also gains +1 health"
      };

    case 43:
      return {
        id,
        cardId: 43,
        name: 'Ettin',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.BRUTE,
        cost: 5,
        attack: 6,
        health: 3,
        text: "On Attack: Gains +2 health if the enemy is a Hunter"
      };

    case 44:
      return {
        id,
        cardId: 44,
        name: 'Cyclops',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.BRUTE,
        cost: 4,
        attack: 3,
        health: 4,
        text: "When Played: Reduce the enemy's attack by 1 if the enemy is a Hunter. If another Brute ally is in play, Cyclops gains +1 attack"
      };

    case 45:
      return {
        id,
        cardId: 45,
        name: 'Giant',
        cardType: types.CREATURE,
        cardTier: 3,
        creatureType: tags.BRUTE,
        cost: 1,
        attack: 2,
        health: 3,
        text: "On Death: Grants +1 health to the hero if the enemy is a Hunter. If Giant is the only Brute in play, this bonus is doubled"
      };

    case 46:
      return {
        id,
        cardId: 46,
        name: 'Goblin',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.MAGICAL,
        cost: 2,
        attack: 2,
        health: 3,
        text: "On Attack: Deals 1 extra damage if the enemy is a Brute. Gains +1 attack after it attacks"
      };

    case 47:
      return {
        id,
        cardId: 47,
        name: 'Ghoul',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.MAGICAL,
        cost: 2,
        attack: 2,
        health: 2,
        text: "When Played: Reduce the enemy's attack by 1 if it's a Brute"
      };

    case 48:
      return {
        id,
        cardId: 48,
        name: 'Wraith',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.MAGICAL,
        cost: 3,
        attack: 3,
        health: 2,
        text: "On Death: Grants +2 health to the hero if another Magical ally is in play"
      };

    case 49:
      return {
        id,
        cardId: 49,
        name: 'Sprite',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.MAGICAL,
        cost: 2,
        attack: 2,
        health: 3,
        text: "When Played: Increase the attack of all other Magical allies by 1"
      };

    case 50:
      return {
        id,
        cardId: 50,
        name: 'Kappa',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.MAGICAL,
        cost: 4,
        attack: 4,
        health: 4,
        text: "On Attack: Gains +1 attack if the enemy is a Brute"
      };

    case 51:
      return {
        id,
        cardId: 51,
        name: 'Hippogriff',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.HUNTER,
        cost: 1,
        attack: 3,
        health: 1,
        text: "When Played: Deals 1 damage if the enemy is Magical"
      };

    case 52:
      return {
        id,
        cardId: 52,
        name: 'Fenrir',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.HUNTER,
        cost: 2,
        attack: 2,
        health: 2,
        text: "On Attack: Deals 1 extra damage if another Hunter ally is in play. Gains +1 health if there are no other Hunter allies"
      };

    case 53:
      return {
        id,
        cardId: 53,
        name: 'Jaguar',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.HUNTER,
        cost: 3,
        attack: 4,
        health: 3,
        text: "On Death: Grants +1 attack to the next Hunter played if the enemy is Magical"
      };

    case 54:
      return {
        id,
        cardId: 54,
        name: 'Satori',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.HUNTER,
        cost: 4,
        attack: 4,
        health: 2,
        text: "When Played: Marks the enemy to take 1 additional damage if it's Magical"
      };

    case 55:
      return {
        id,
        cardId: 55,
        name: 'Direwolf',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.HUNTER,
        cost: 2,
        attack: 2,
        health: 2,
        text: "On Attack: Deals 1 extra damage to the enemy if it's Magical"
      };

    case 56:
      return {
        id,
        cardId: 56,
        name: 'Nemeanlion',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.BRUTE,
        cost: 3,
        attack: 3,
        health: 4,
        text: "On Death: Grants +1 attack to all Brute allies if the enemy is a Hunter"
      };

    case 57:
      return {
        id,
        cardId: 57,
        name: 'Berserker',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.BRUTE,
        cost: 2,
        attack: 3,
        health: 2,
        text: "On Attack: Deals 1 extra damage if the enemy is a Hunter"
      };

    case 58:
      return {
        id,
        cardId: 58,
        name: 'Yeti',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.BRUTE,
        cost: 1,
        attack: 3,
        health: 2,
        text: "When Played: Gains +1 health if there is another Brute ally in play"
      };

    case 59:
      return {
        id,
        cardId: 59,
        name: 'Golem',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.BRUTE,
        cost: 4,
        attack: 4,
        health: 2,
        text: "When Played: Reduce the enemy's attack by 1 if the enemy is a Hunter"
      };

    case 60:
      return {
        id,
        cardId: 60,
        name: 'Ent',
        cardType: types.CREATURE,
        cardTier: 4,
        creatureType: tags.BRUTE,
        cost: 2,
        attack: 2,
        health: 3,
        text: "On Death: Grants +2 health to the hero if the enemy is a Hunter"
      };

    case 61:
      return {
        id,
        cardId: 61,
        name: 'Fairy',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.MAGICAL,
        cost: 4,
        attack: 3,
        health: 3,
        text: "On Death: Reduce the enemy's attack by 1 if it's a Brute"
      };

    case 62:
      return {
        id,
        cardId: 62,
        name: 'Leprechaun',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.MAGICAL,
        cost: 2,
        attack: 2,
        health: 2,
        text: "On Attack: Deals 1 extra damage if there is another Magical ally in play"
      };

    case 63:
      return {
        id,
        cardId: 63,
        name: 'Kelpie',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.MAGICAL,
        cost: 1,
        attack: 1,
        health: 1,
        text: "When Played: Gain +2 attack if the enemy is a Brute"
      };

    case 64:
      return {
        id,
        cardId: 64,
        name: 'Pixie',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.MAGICAL,
        cost: 3,
        attack: 2,
        health: 3,
        text: "On Death: Grants +2 health to the hero if the enemy is a Brute"
      };

    case 65:
      return {
        id,
        cardId: 65,
        name: 'Gnome',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.MAGICAL,
        cost: 5,
        attack: 4,
        health: 4,
        text: "On Attack: Deals 1 extra damage if the enemy is a Brute"
      };

    case 66:
      return {
        id,
        cardId: 66,
        name: 'Bear',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.HUNTER,
        cost: 4,
        attack: 3,
        health: 2,
        text: "When Played: Deals 1 damage if the enemy is Magical"
      };

    case 67:
      return {
        id,
        cardId: 67,
        name: 'Wolf',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.HUNTER,
        cost: 2,
        attack: 2,
        health: 2,
        text: "On Attack: Deals 1 extra damage if another Hunter ally is in play"
      };

    case 68:
      return {
        id,
        cardId: 68,
        name: 'Mantis',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.HUNTER,
        cost: 1,
        attack: 1,
        health: 1,
        text: "On Death: Grants +1 attack to the next Hunter played if the enemy is Magical"
      };

    case 69:
      return {
        id,
        cardId: 69,
        name: 'Spider',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.HUNTER,
        cost: 3,
        attack: 3,
        health: 2,
        text: "On Attack: Deals 1 extra damage if the enemy is Magical"
      };

    case 70:
      return {
        id,
        cardId: 70,
        name: 'Rat',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.HUNTER,
        cost: 5,
        attack: 4,
        health: 4,
        text: "When Played: Gains +1 attack if there's another Hunter ally in play"
      };

    case 71:
      return {
        id,
        cardId: 71,
        name: 'Troll',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.BRUTE,
        cost: 4,
        attack: 3,
        health: 4,
        text: "On Death: Grants +1 attack to all Brute allies if the enemy is a Hunter"
      };

    case 72:
      return {
        id,
        cardId: 72,
        name: 'Bigfoot',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.BRUTE,
        cost: 2,
        attack: 3,
        health: 2,
        text: "When Played: Deals 1 damage if the enemy is a Hunter"
      };

    case 73:
      return {
        id,
        cardId: 73,
        name: 'Ogre',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.BRUTE,
        cost: 1,
        attack: 1,
        health: 2,
        text: "On Death: Grants +1 health to the hero if the enemy is a Hunter"
      };

    case 74:
      return {
        id,
        cardId: 74,
        name: 'Orc',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.BRUTE,
        cost: 4,
        attack: 2,
        health: 3,
        text: "When Played: Reduce the enemy's attack by 1 if it's a Hunter"
      };

    case 75:
      return {
        id,
        cardId: 75,
        name: 'Skeleton',
        cardType: types.CREATURE,
        cardTier: 5,
        creatureType: tags.BRUTE,
        cost: 5,
        attack: 4,
        health: 4,
        text: "On Attack: Deals 1 extra damage if there is another Brute ally in play"
      };

    case 76:
      return {
        id,
        cardId: 76,
        name: "Warlock Pact",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 1,
        cost: 1,
        attack: 0,
        health: 0,
        text: "You gain 3 energy"
      }

    case 77:
      return {
        id,
        cardId: 77,
        name: "Dragon Breath",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 1,
        cost: 1,
        attack: 0,
        health: 0,
        text: "Deal 4 damage to the enemy. Double this damage if the enemy is a magical"
      }

    case 78:
      return {
        id,
        cardId: 78,
        name: "Jiangshi Curse",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 1,
        cost: 2,
        attack: 0,
        health: 0,
        text: "Marks the enemy to take 2 additional damage."
      }

    case 79:
      return {
        id,
        cardId: 79,
        name: "Gorgon Gaze",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 2,
        cost: 3,
        attack: 0,
        health: 0,
        text: "Reduce the enemy's attack by 1"
      }

    case 80:
      return {
        id,
        cardId: 80,
        name: "Titan Call",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 2,
        cost: 1,
        attack: 0,
        health: 0,
        text: "Your brutes gain +3 attack"
      }

    case 81:
      return {
        id,
        cardId: 81,
        name: "Wendigo Frenzy",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 2,
        cost: 2,
        attack: 0,
        health: 0,
        text: "Your creatures gain +3 attack"
      }

    case 82:
      return {
        id,
        cardId: 82,
        name: "Giant Shoulders",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 3,
        cost: 2,
        attack: 0,
        health: 0,
        text: "Heal your hero 1 for each Brute ally in play"
      }

    case 83:
      return {
        id,
        cardId: 83,
        name: "Werewolf Howl",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 3,
        cost: 3,
        attack: 0,
        health: 0,
        text: "Your Hunter creatures gain +3 attack and +3 health"
      }

    case 84:
      return {
        id,
        cardId: 84,
        name: "Vampire Bite",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 3,
        cost: 5,
        attack: 0,
        health: 0,
        text: "Deal 3 damage to the enemy and heal your hero for 3"
      }

    case 85:
      return {
        id,
        cardId: 85,
        name: "Wraith Shadow",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 4,
        cost: 1,
        attack: 0,
        health: 0,
        text: "Deal 4 damage to the enemy"
      }

    case 86:
      return {
        id,
        cardId: 86,
        name: "Sprite Favor",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 4,
        cost: 5,
        attack: 0,
        health: 0,
        text: "Restore 4 health to your hero"
      }

    case 87:
      return {
        id,
        cardId: 87,
        name: "Kappa Gift",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 4,
        cost: 1,
        attack: 0,
        health: 0,
        text: "Your creatures gain +2 health"
      }

    case 88:
      return {
        id,
        cardId: 88,
        name: "Ogre Strength",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 5,
        cost: 1,
        attack: 0,
        health: 0,
        text: "Your brutes gain +1 attack and +1 health"
      }

    case 89:
      return {
        id,
        cardId: 89,
        name: "Kitsune Blessing",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 5,
        cost: 1,
        attack: 0,
        health: 0,
        text: "Your magical creatures gain +1 attack and +1 health"
      }

    case 90:
      return {
        id,
        cardId: 90,
        name: "Bear Foot",
        cardType: types.SPELL,
        creatureType: tags.SPELL,
        cardTier: 5,
        cost: 1,
        attack: 0,
        health: 0,
        text: "Your hunters gain +1 attack and +1 health"
      }

    default:
      return {
        id,
        cardId: 0,
        name: 'Unknown',
        cardType: 'None',
        creatureType: 'None',
        cardTier: 0,
        cost: 2,
        attack: 0,
        health: 0,
        text: ""
      }
  }
}

export const CardSize = {
  big: { height: '330px', width: '252px' },
  large: { height: '275px', width: '210px' },
  medium: { height: '220px', width: '168px' },
  small: { height: '110px', width: '84px' }
}