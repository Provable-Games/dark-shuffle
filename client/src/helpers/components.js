import { dojoConfig } from "../../dojo.config"

export const get_short_namespace = () => {
  let parts = dojoConfig.namespace.split('_');
  let short = parts[0] + parts.slice(1).map(word => word.charAt(0).toUpperCase() + word.slice(1)).join('');
  return short;
}

export const translateName = (selector) => {
  const model = dojoConfig.manifest.models.find(model => model.selector === selector);
  return model?.tag?.split('-')[1];
}

export const components = {
  // Config Models
  'WorldConfig': {
    configId: Number(),
    gameTokenAddress: null,
    gameCount: Number(),
  },

  // Game Models
  'Game': {
    gameId: Number(),
    heroHealth: Number(),
    heroXp: Number(),
    monstersSlain: Number(),
    mapLevel: Number(),
    mapDepth: Number(),
    lastNodeId: Number(),
    actionCount: Number(),
    state: Number(),
  },
  'GameEffects': {
    gameId: Number(),
    firstAttack: Number(),
    firstHealth: Number(),
    firstCreatureCost: Number(),
    allAttack: Number(),
    hunterAttack: Number(),
    hunterHealth: Number(),
    magicalAttack: Number(),
    magicalHealth: Number(),
    bruteAttack: Number(),
    bruteHealth: Number(),
    heroDmgReduction: Number(),
    heroCardHeal: Boolean(),
    cardDraw: Number(),
    playCreatureHeal: Number(),
    startBonusEnergy: Number(),
  },
  'TokenMetadata': {
    tokenId: Number(),
    mintedBy: null,
    playerName: String(),
    settingsId: Number(),
    mintedAt: Number(),
    availableAt: Number(),
    expiresAt: Number(),
  },

  // Draft Models
  'Draft': {
    gameId: Number(),
    options: 'array',
    cards: 'array',
  },

  // Battle models
  'Battle': {
    battleId: Number(),
    gameId: Number(),

    round: Number(),
    hero: 'Hero',
    monster: 'Monster',

    hand: 'array',
    deck: 'array',
    deckIndex: Number(),

    battleEffects: 'BattleEffects',
  },
  'Board': {
    battleId: Number(),
    gameId: Number(),
    creature1: 'Creature',
    creature2: 'Creature',
    creature3: 'Creature',
    creature4: 'Creature',
    creature5: 'Creature',
    creature6: 'Creature',
  },

  // Map models
  'Map': {
    gameId: Number(),
    level: Number(),
    seed: Number(),
  },
}
