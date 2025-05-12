import { Box, Typography } from '@mui/material'
import { tags } from '../helpers/cards'

export const MONSTER_LIST = () => {
  return Array(75).fill(0).map((_, i) => {
    return get_monster_details(i + 1)
  })
}

export const GET_MONSTER = (monsterId, fullName, gameSettings) => {
  let details = get_monster_details(monsterId)

  return {
    id: monsterId,
    monsterId: monsterId,
    name: details.name,
    monsterType: details.monsterType,
    abilities: <>
      <Typography color="primary">{fullName}</Typography>
      {getMonsterAbilities(monsterId, gameSettings?.persistent_health)}
    </>
  }
}

const getMonsterAbilities = (monsterId, persistentHealth) => {
  switch (Number(monsterId)) {
    case 75:
      return formatAbility({
        effect: "Skeleton takes one less damage from Hunters.",
        reward: "Your Magical beasts get +1 attack when played."
      })
    case 74:
      return formatAbility({
        effect: "Orc deals one extra damage to Hunters.",
        reward: "Your Magical beasts get +1 health when played."
      })
    case 73:
      return formatAbility({
        effect: "Gains +1 attack each time a Hunter is played.",
        reward: "Your Magical beasts get +1 attack when played."
      })
    case 72:
      return formatAbility({
        effect: "Gains +2 health each time a Hunter is played.",
        reward: "Your Magical beasts get +1 health when played."
      })
    case 71:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 5 health."
      }) : null;
    case 70:
      return formatAbility({
        effect: "Rat takes one less damage from Magical beasts.",
        reward: "Your Brutes get +1 attack when played."
      })
    case 69:
      return formatAbility({
        effect: "Spider deals one extra damage to Magical beasts.",
        reward: "Your Brutes get +1 health when played."
      })
    case 68:
      return formatAbility({
        effect: "Gains +1 attack each time a Magical beast is played.",
        reward: "Your Brutes get +1 attack when played."
      })
    case 67:
      return formatAbility({
        effect: "Gains +2 health each time a Magical beast is played.",
        reward: "Your Brutes get +1 health when played."
      })
    case 66:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 5 health."
      }) : null;
    case 65:
      return formatAbility({
        effect: "Gnome takes one less damage from Brutes.",
        reward: "Your Hunters get +1 attack when played."
      })
    case 64:
      return formatAbility({
        effect: "Pixie deals one extra damage to Brutes.",
        reward: "Your Hunters get +1 health when played."
      })
    case 63:
      return formatAbility({
        effect: "Kelpie gains +1 attack each time a Brute is played.",
        reward: "Your Hunters get +1 attack when played."
      })
    case 62:
      return formatAbility({
        effect: "Leprechaun gains +2 health each time a Brute is played.",
        reward: "Your Hunters get +1 health when played."
      })
    case 61:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 5 health."
      }) : null;
    case 60:
      return formatAbility({
        effect: "Ent gains +1 attack each time a Brute is played.",
        reward: "Your Hunters get +1 attack when played."
      })
    case 59:
      return formatAbility({
        ability: "Golem gains +2 attack if you didn't deal damage this turn.",
        reward: "You start with +1 energy."
      })
    case 58:
      return formatAbility({
        ability: "Yeti gains +1 attack if it has less attack than your strongest beast.",
        reward: "You start with +1 energy."
      })
    case 57:
      return formatAbility({
        ability: "Berserker gains +2 health if it has less attack than your strongest beast.",
        reward: "The first beast you play each turn gets +2 health."
      })
    case 56:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 10 health."
      }) : null;
    case 55:
      return formatAbility({
        ability: "Deals 2 damage to your hero whenever you play a beast with higher health than its attack.",
        reward: "The first beast you play each turn gets +1 attack."
      })
    case 54:
    case 53:
    case 52:
    case 51:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 10 health."
      }) : null;
    case 50:
    case 49:
    case 48:
    case 47:
    case 46:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 10 health."
      }) : null;
    case 45:
    case 44:
    case 43:
    case 42:
    case 41:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 15 health."
      }) : null;
    case 40:
    case 39:
    case 38:
    case 37:
    case 36:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 15 health."
      }) : null;
    case 35:
    case 34:
    case 33:
    case 32:
    case 31:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 15 health."
      }) : null;
    case 30:
      return formatAbility({
        ability: "Deals 3 damage to your hero if you didn't deal damage this turn.",
        reward: "The first beast you play each turn gets +1 attack."
      })
    case 29:
    case 28:
    case 27:
    case 26:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 20 health."
      }) : null;
    case 25:
    case 24:
    case 23:
    case 22:
    case 21:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 20 health."
      }) : null;
    case 20:
      return formatAbility({
        ability: "Wendigo gains +1 attack for each beast in your hand.",
        reward: "Your beasts get +1 attack when played."
      })
    case 19:
    case 18:
    case 17:
    case 16:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 20 health."
      }) : null;
    case 15:
      return formatAbility({
        ability: "Tarrasque gains +1 attack for each beast that attacked it this turn.",
        reward: "You restore 1 health each time you play a beast."
      })
    case 14:
    case 13:
    case 12:
    case 11:
    case 10:
    case 9:
    case 8:
    case 7:
    case 6:
    case 5:
    case 4:
      return persistentHealth ? formatAbility({
        reward: "Your hero restores 20 health."
      }) : null;
    case 3:
      return formatAbility({
        effect: "Jiangshi starts with +1 attack and +1 health for each Brute in your deck.",
        reward: "Your Hunters get +2 attack and +2 health when played."
      })
    case 2:
      return formatAbility({
        ability: "Typhon deals damage to your hero equal to the number of cards in your hand.",
        reward: "When you end your turn, your hero restores health equal to the number of cards in your hand."
      })
    case 1:
      return formatAbility({
        ability: "Warlock destroys a random card from your hand.",
        reward: "You draw an extra card each turn."
      })
    default:
      return <></>
  }
}

const formatAbility = ({ ability, effect, reward }) => {
  return <>
    {ability && <Box sx={{ display: 'flex', alignItems: 'center', mt: 1 }}>
      <Typography color="#ffb260">Ability:</Typography>
    </Box>}
    {ability && <Typography mt={0.5}>
      {ability}
    </Typography>}

    {effect && <Box sx={{ display: 'flex', alignItems: 'center', mt: 1 }}>
      <Typography color="#ffb260">Effect:</Typography>
    </Box>}
    {effect && <Typography mt={0.5}>
      {effect}
    </Typography>}

    {reward && <Box sx={{ display: 'flex', alignItems: 'center', mt: 1 }}>
      <Typography color="#ffb260">Reward:</Typography>
    </Box>}
    {reward && <Typography mt={0.5}>
      {reward}
    </Typography>}
  </>
}

export const BEAST_NAME_PREFIXES = {
  1: "Agony",
  2: "Apocalypse",
  3: "Armageddon",
  4: "Beast",
  5: "Behemoth",
  6: "Blight",
  7: "Blood",
  8: "Bramble",
  9: "Brimstone",
  10: "Brood",
  11: "Carrion",
  12: "Cataclysm",
  13: "Chimeric",
  14: "Corpse",
  15: "Corruption",
  16: "Damnation",
  17: "Death",
  18: "Demon",
  19: "Dire",
  20: "Dragon",
  21: "Dread",
  22: "Doom",
  23: "Dusk",
  24: "Eagle",
  25: "Empyrean",
  26: "Fate",
  27: "Foe",
  28: "Gale",
  29: "Ghoul",
  30: "Gloom",
  31: "Glyph",
  32: "Golem",
  33: "Grim",
  34: "Hate",
  35: "Havoc",
  36: "Honour",
  37: "Horror",
  38: "Hypnotic",
  39: "Kraken",
  40: "Loath",
  41: "Maelstrom",
  42: "Mind",
  43: "Miracle",
  44: "Morbid",
  45: "Oblivion",
  46: "Onslaught",
  47: "Pain",
  48: "Pandemonium",
  49: "Phoenix",
  50: "Plague",
  51: "Rage",
  52: "Rapture",
  53: "Rune",
  54: "Skull",
  55: "Sol",
  56: "Soul",
  57: "Sorrow",
  58: "Spirit",
  59: "Storm",
  60: "Tempest",
  61: "Torment",
  62: "Vengeance",
  63: "Victory",
  64: "Viper",
  65: "Vortex",
  66: "Woe",
  67: "Wrath",
  68: "Lights",
  69: "Shimmering",
};

export const BEAST_NAME_SUFFIXES = {
  1: "Bane",
  2: "Root",
  3: "Bite",
  4: "Song",
  5: "Roar",
  6: "Grasp",
  7: "Instrument",
  8: "Glow",
  9: "Bender",
  10: "Shadow",
  11: "Whisper",
  12: "Shout",
  13: "Growl",
  14: "Tear",
  15: "Peak",
  16: "Form",
  17: "Sun",
  18: "Moon",
};

export const get_monster_details = (monsterId) => {
  switch (monsterId) {
    case 1:
      return {
        name: 'Warlock',
        monsterType: tags.MAGICAL,
      };

    case 2:
      return {
        name: 'Typhon',
        monsterType: tags.MAGICAL,
      };

    case 3:
      return {
        name: 'Jiangshi',
        monsterType: tags.MAGICAL,
      };

    case 4:
      return {
        name: 'Anansi',
        monsterType: tags.MAGICAL,
      };

    case 5:
      return {
        name: 'Basilisk',
        monsterType: tags.MAGICAL,
      };

    case 6:
      return {
        name: 'Griffin',
        monsterType: tags.HUNTER,
      };

    case 7:
      return {
        name: 'Manticore',
        monsterType: tags.HUNTER,
      };

    case 8:
      return {
        name: 'Phoenix',
        monsterType: tags.HUNTER,
      };

    case 9:
      return {
        name: 'Dragon',
        monsterType: tags.HUNTER,
      };

    case 10:
      return {
        name: 'Minotaur',
        monsterType: tags.HUNTER,
      };

    case 11:
      return {
        name: 'Kraken',
        monsterType: tags.BRUTE,
      };

    case 12:
      return {
        name: 'Colossus',
        monsterType: tags.BRUTE,
      };

    case 13:
      return {
        name: 'Balrog',
        monsterType: tags.BRUTE,
      };

    case 14:
      return {
        name: 'Leviathan',
        monsterType: tags.BRUTE,
      };

    case 15:
      return {
        name: 'Tarrasque',
        monsterType: tags.BRUTE,
      };

    case 16:
      return {
        name: 'Gorgon',
        monsterType: tags.MAGICAL,
      };

    case 17:
      return {
        name: 'Kitsune',
        monsterType: tags.MAGICAL,
      };

    case 18:
      return {
        name: 'Lich',
        monsterType: tags.MAGICAL,
      };

    case 19:
      return {
        name: 'Chimera',
        monsterType: tags.MAGICAL,
      };

    case 20:
      return {
        name: 'Wendigo',
        monsterType: tags.MAGICAL,
      };

    case 21:
      return {
        name: 'Qilin',
        monsterType: tags.HUNTER,
      };

    case 22:
      return {
        name: 'Ammit',
        monsterType: tags.HUNTER,
      };

    case 23:
      return {
        name: 'Nue',
        monsterType: tags.HUNTER,
      };

    case 24:
      return {
        name: 'Skinwalker',
        monsterType: tags.HUNTER,
      };

    case 25:
      return {
        name: 'Chupacabra',
        monsterType: tags.HUNTER,
      };

    case 26:
      return {
        name: 'Titan',
        monsterType: tags.BRUTE,
      };

    case 27:
      return {
        name: 'Nephilim',
        monsterType: tags.BRUTE,
      };

    case 28:
      return {
        name: 'Behemoth',
        monsterType: tags.BRUTE,
      };

    case 29:
      return {
        name: 'Hydra',
        monsterType: tags.BRUTE,
      };

    case 30:
      return {
        name: 'Juggernaut',
        monsterType: tags.BRUTE,
      };

    case 31:
      return {
        name: 'Rakshasa',
        monsterType: tags.MAGICAL,
      };

    case 32:
      return {
        name: 'Werewolf',
        monsterType: tags.MAGICAL,
      };

    case 33:
      return {
        name: 'Banshee',
        monsterType: tags.MAGICAL,
      };

    case 34:
      return {
        name: 'Draugr',
        monsterType: tags.MAGICAL,
      };

    case 35:
      return {
        name: 'Vampire',
        monsterType: tags.MAGICAL,
      };

    case 36:
      return {
        name: 'Weretiger',
        monsterType: tags.HUNTER,
      };

    case 37:
      return {
        name: 'Wyvern',
        monsterType: tags.HUNTER,
      };

    case 38:
      return {
        name: 'Roc',
        monsterType: tags.HUNTER,
      };

    case 39:
      return {
        name: 'Harpy',
        monsterType: tags.HUNTER,
      };

    case 40:
      return {
        name: 'Pegasus',
        monsterType: tags.HUNTER,
      };

    case 41:
      return {
        name: 'Oni',
        monsterType: tags.BRUTE,
      };

    case 42:
      return {
        name: 'Jotunn',
        monsterType: tags.BRUTE,
      };

    case 43:
      return {
        name: 'Ettin',
        monsterType: tags.BRUTE,
      };

    case 44:
      return {
        name: 'Cyclops',
        monsterType: tags.BRUTE,
      };

    case 45:
      return {
        name: 'Giant',
        monsterType: tags.BRUTE,
      };

    case 46:
      return {
        name: 'Goblin',
        monsterType: tags.MAGICAL,
      };

    case 47:
      return {
        name: 'Ghoul',
        monsterType: tags.MAGICAL,
      };

    case 48:
      return {
        name: 'Wraith',
        monsterType: tags.MAGICAL,
      };

    case 49:
      return {
        name: 'Sprite',
        monsterType: tags.MAGICAL,
      };

    case 50:
      return {
        name: 'Kappa',
        monsterType: tags.MAGICAL,
      };

    case 51:
      return {
        name: 'Hippogriff',
        monsterType: tags.HUNTER,
      };

    case 52:
      return {
        name: 'Fenrir',
        monsterType: tags.HUNTER,
      };

    case 53:
      return {
        name: 'Jaguar',
        monsterType: tags.HUNTER,
      };

    case 54:
      return {
        name: 'Satori',
        monsterType: tags.HUNTER,
      };

    case 55:
      return {
        name: 'Direwolf',
        monsterType: tags.HUNTER,
      };

    case 56:
      return {
        name: 'Nemeanlion',
        monsterType: tags.BRUTE,
      };

    case 57:
      return {
        name: 'Berserker',
        monsterType: tags.BRUTE,
      };

    case 58:
      return {
        name: 'Yeti',
        monsterType: tags.BRUTE,
      };

    case 59:
      return {
        name: 'Golem',
        monsterType: tags.BRUTE,
      };

    case 60:
      return {
        name: 'Ent',
        monsterType: tags.BRUTE,
      };

    case 61:
      return {
        name: 'Fairy',
        monsterType: tags.MAGICAL,
      };

    case 62:
      return {
        name: 'Leprechaun',
        monsterType: tags.MAGICAL,
      };

    case 63:
      return {
        name: 'Kelpie',
        monsterType: tags.MAGICAL,
      };

    case 64:
      return {
        name: 'Pixie',
        monsterType: tags.MAGICAL,
      };

    case 65:
      return {
        name: 'Gnome',
        monsterType: tags.MAGICAL,
      };

    case 66:
      return {
        name: 'Bear',
        monsterType: tags.HUNTER,
      };

    case 67:
      return {
        name: 'Wolf',
        monsterType: tags.HUNTER,
      };

    case 68:
      return {
        name: 'Mantis',
        monsterType: tags.HUNTER,
      };

    case 69:
      return {
        name: 'Spider',
        monsterType: tags.HUNTER,
      };

    case 70:
      return {
        name: 'Rat',
        monsterType: tags.HUNTER,
      };

    case 71:
      return {
        name: 'Troll',
        monsterType: tags.BRUTE,
      };

    case 72:
      return {
        name: 'Bigfoot',
        monsterType: tags.BRUTE,
      };

    case 73:
      return {
        name: 'Ogre',
        monsterType: tags.BRUTE,
      };

    case 74:
      return {
        name: 'Orc',
        monsterType: tags.BRUTE,
      };

    case 75:
      return {
        name: 'Skeleton',
        monsterType: tags.BRUTE,
      };
    default:
      return {
        name: 'Unknown',
        monsterType: 'None',
      };
  }
}