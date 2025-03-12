import { dojoConfig } from "../../dojo.config"

export const get_short_namespace = (namespace) => {
  let parts = namespace.split('_');
  let short = parts[0] + parts.slice(1).map(word => word.charAt(0).toUpperCase() + word.slice(1)).join('');
  return short;
}

export const translateName = (selector) => {
  const model = dojoConfig.manifest.models.find(model => model.selector === selector);
  return model?.tag?.split('-')[1];
}

export const components = {
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

    battleEffects: 'BattleEffects',
  },
  'BattleResources': {
    battleId: Number(),
    gameId: Number(),
    hand: 'array',
    deck: 'array',
    board: 'CreatureArray',
  },

  // Map models
  'Map': {
    gameId: Number(),
    level: Number(),
    seed: Number(),
  },
}
