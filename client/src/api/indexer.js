import { getContractByName } from "@dojoengine/core";
import { getEntityIdFromKeys, hexToAscii } from "@dojoengine/utils";
import { gql, request } from 'graphql-request';
import { dojoConfig } from '../../dojo.config';
import { cardTypes, formatCardEffect, rarities, types } from "../helpers/cards";
import { get_short_namespace } from '../helpers/components';
import { delay } from "../helpers/utilities";

let NS = dojoConfig.namespace;
let NS_SHORT = get_short_namespace(NS);
let GAME_ADDRESS = getContractByName(dojoConfig.manifest, dojoConfig.namespace, "game_systems")?.address
let GQL_ENDPOINT = dojoConfig.toriiUrl + "/graphql"
let SQL_ENDPOINT = dojoConfig.toriiUrl + "/sql"

let TOURNAMENT_NS = dojoConfig.tournamentNamespace;
let TOURNAMENT_NS_SHORT = get_short_namespace(TOURNAMENT_NS);
let ETERNUM_QUEST_ADDRESS = dojoConfig.eternumQuestAddress.toLowerCase();

export async function getTournament(tournament_id) {
  const document = gql`
  {
    ${TOURNAMENT_NS_SHORT}TournamentModels(where:{id:"${tournament_id}"}) {
      edges {
        node {
          id,
          schedule {
            game {
              start,
              end
            },
            submission_duration
          },
          game_config {
            settings_id
          },
          entry_fee {
            Some {
              amount
              distribution
            }
          }
        }
      }
    }
    ${TOURNAMENT_NS_SHORT}EntryCountModels(where:{tournament_id:"${tournament_id}"}) {
      edges {
        node {
          count
        }
      }
    }
    ${TOURNAMENT_NS_SHORT}LeaderboardModels(where:{tournament_id:"${tournament_id}"}) {
      edges {
        node {
          token_ids
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document)
  return {
    tournament: res?.[`${TOURNAMENT_NS_SHORT}TournamentModels`]?.edges[0]?.node,
    entryCount: res?.[`${TOURNAMENT_NS_SHORT}EntryCountModels`]?.edges[0]?.node?.count || 0,
    leaderboard: res?.[`${TOURNAMENT_NS_SHORT}LeaderboardModels`]?.edges[0]?.node?.token_ids || []
  }
}

export async function getSettings(settings_id) {
  const document = gql`
  {
    ${NS_SHORT}GameSettingsMetadataModels(where:{settings_id:${settings_id}}) {
      edges {
        node {
          settings_id,
          name,
          description
        }
      }
    }
    ${NS_SHORT}GameSettingsModels(where:{settings_id:${settings_id}}) {
      edges {
        node {
          settings_id,
          starting_health,
          persistent_health,
          map {
            possible_branches,
            level_depth,
            enemy_attack_min,
            enemy_attack_max,
            enemy_health_min,
            enemy_health_max,
            enemy_attack_scaling,
            enemy_health_scaling
          },
          battle {
            start_energy,
            start_hand_size,
            max_energy,
            max_hand_size,
            draw_amount
          },
          draft {
            auto_draft,
            draft_size,
            card_ids,
            card_rarity_weights {
              common,
              uncommon,
              rare,
              epic,
              legendary
            }
          }
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document)

  let gameSettings = res?.[`${NS_SHORT}GameSettingsModels`]?.edges[0]?.node || {}
  let gameSettingsMetadata = res?.[`${NS_SHORT}GameSettingsMetadataModels`]?.edges[0]?.node || {}

  return {
    ...gameSettingsMetadata,
    name: hexToAscii(gameSettingsMetadata.name),
    starting_health: gameSettings.starting_health,
    persistent_health: gameSettings.persistent_health,
    ...gameSettings.map,
    ...gameSettings.battle,
    ...gameSettings.draft,
    card_ids: gameSettings.draft.card_ids.map(cardId => Number(cardId))
  }
}

export async function getActiveGame(game_id, retry = 0) {
  const document = gql`
  {
    ${NS_SHORT}GameModels (where:{
      game_id:"${game_id}"
    }) {
      edges {
        node {
          game_id,
          state,

          hero_health,
          hero_xp,
          monsters_slain,
          
          map_level,
          map_depth,
          last_node_id
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document)

  if (!res?.[`${NS_SHORT}GameModels`]?.edges || res?.[`${NS_SHORT}GameModels`]?.edges.length === 0) {
    if (retry < 60) {
      await delay(1000);
      return getActiveGame(game_id, retry + 1);
    }

    return null
  }

  return res?.[`${NS_SHORT}GameModels`]?.edges[0]?.node;
}

export async function getDraft(game_id) {
  const document = gql`
    {
      ${NS_SHORT}DraftModels (where:{
      game_id:"${game_id}"
    }) {
      edges {
        node {
          game_id
          options
          cards
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document)
  return res?.[`${NS_SHORT}DraftModels`]?.edges[0]?.node;
}

export async function getGameEffects(game_id) {
  const document = gql`
  {
    ${NS_SHORT}GameEffectsModels(where:{game_id:"${game_id}"}) {
      edges {
        node {
          game_id,
          first_attack,
          first_health,
          all_attack,
          hunter_attack,
          hunter_health,
          magical_attack,
          magical_health,
          brute_attack,
          brute_health,
          hero_dmg_reduction,
          hero_card_heal,
          card_draw,
          play_creature_heal,
          start_bonus_energy
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document);

  return res?.[`${NS_SHORT}GameEffectsModels`]?.edges[0]?.node;
}

export async function getMap(game_id, level) {
  const document = gql`
  {
    ${NS_SHORT}MapModels(where:{game_id:"${game_id}", level:${level}}) {
      edges {
        node {
          game_id,
          level,
          seed
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document);

  return res?.[`${NS_SHORT}MapModels`]?.edges[0]?.node;
}

export async function getBattleState(battle_id, game_id) {
  const document = gql`
  {
    entity (id:"${getEntityIdFromKeys([BigInt(battle_id), BigInt(game_id)])}") {
      models {
        ... on ${NS}_Battle {
          battle_id
          game_id
          round

          hero {
            health
            energy
          }

          monster {
            monster_id
            attack
            health
          }
          
          battle_effects { 
            enemy_marks
            hero_dmg_reduction
            next_hunter_attack_bonus
            next_hunter_health_bonus
            next_brute_attack_bonus
            next_brute_health_bonus
            next_magical_attack_bonus
            next_magical_health_bonus
          }
        }
        ... on ${NS}_BattleResources {
          hand
          deck
          board {
            card_index
            attack
            health
          }
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document);

  const result = {
    battle: res?.entity.models.find(model => model.hero),
    battleResources: res?.entity.models.find(model => model.hand)
  };

  return result;
}

export async function getTournamentRegistrations(tournament_id) {
  const document = gql`
  {
    ${TOURNAMENT_NS_SHORT}RegistrationModels(where:{tournament_id:"${tournament_id}"}, limit: 10000) {
      edges {
        node {
          game_token_id
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document)

  return res?.[`${TOURNAMENT_NS_SHORT}RegistrationModels`]?.edges.map(edge => parseInt(edge.node.game_token_id, 16))
}


export async function getLeaderboard(page, game_token_ids) {
  let gameIds = game_token_ids.map(tokenId => `"${tokenId.toString()}"`);
  let pageSize = 10;

  try {
    const document = gql`
    {
      ${NS_SHORT}GameModels (where: {hero_health: 0, game_idIN:[${gameIds}]}, order:{field:HERO_XP, direction:DESC}, limit:${pageSize}, offset:${pageSize * page}) {
        edges {
          node {
            game_id,
            hero_xp
          }
        }
      }
    }
  `
    const res = await request(GQL_ENDPOINT, document);

    return res?.[`${NS_SHORT}GameModels`]?.edges.map(edge => edge.node);
  } catch (ex) {
    console.log(ex)
  }
}

export async function getActiveLeaderboard(page, game_token_ids) {
  let gameIds = game_token_ids.map(tokenId => `"${tokenId.toString()}"`);
  let pageSize = 10;

  try {
    const document = gql`
    {
      ${NS_SHORT}GameModels (where: {hero_healthGT: 0, game_idIN:[${gameIds}]}, order:{field:HERO_XP, direction:DESC}, limit:${pageSize}, offset:${pageSize * page}) {
        edges {
          node {
            game_id,
            hero_xp
          }
        }
      }
    }
  `
    const res = await request(GQL_ENDPOINT, document);

    return res?.[`${NS_SHORT}GameModels`]?.edges.map(edge => edge.node);
  } catch (ex) {
    console.log(ex)
  }
}

export async function getGameTxs(game_id) {
  const document = gql`
  {
    ${NS_SHORT}GameActionEventModels(where:{game_id:"${game_id}"}, order:{field:COUNT, direction:ASC}, limit:10000) {
      edges {
        node {
          game_id
          tx_hash
          count
        }
      }
    }
  }
  `

  const res = await request(GQL_ENDPOINT, document);

  return res?.[`${NS_SHORT}GameActionEventModels`]?.edges.map(edge => edge.node);
}

export const getGameTokens = async (accountAddress) => {
  let url = `${SQL_ENDPOINT}?query=
    SELECT token_id FROM token_balances
    WHERE account_address = "${accountAddress.replace(/^0x0+/, "0x")}" AND contract_address = "${GAME_ADDRESS}"
    LIMIT 10000`

  const sql = await fetch(url, {
    method: "GET",
    headers: {
      "Content-Type": "application/json"
    }
  })

  let data = await sql.json()
  return data.map(token => parseInt(token.token_id.split(":")[1], 16))
}

export const populateGameTokens = async (tokenIds) => {
  tokenIds = tokenIds.map(tokenId => `"${tokenId.toString()}"`);

  const document = gql`
  {
    ${NS_SHORT}TokenMetadataModels (limit:10000, where:{
      token_idIN:[${tokenIds}]}
    ){
      edges {
        node {
          token_id
          player_name
          settings_id
          minted_by
          lifecycle {
            start {
              Some
            }
            end {
              Some
            }
          }
        }
      }
    }

    ${NS_SHORT}GameModels (limit:10000, where:{
      game_idIN:[${tokenIds}]}
    ){
      edges {
        node {
          game_id
          hero_health
          hero_xp
        }
      }
    }
  }`

  try {
    const res = await request(GQL_ENDPOINT, document)
    let tokenMetadata = res?.[`${NS_SHORT}TokenMetadataModels`]?.edges.map(edge => edge.node) ?? []
    let gameData = res?.[`${NS_SHORT}GameModels`]?.edges.map(edge => edge.node) ?? []
    let tournaments = res?.[`${TOURNAMENT_NS_SHORT}RegistrationModels`]?.edges.map(edge => edge.node) ?? []

    let games = tokenMetadata.map(metaData => {
      let game = gameData.find(game => game.game_id === metaData.token_id)
      let tournament = tournaments.find(tournament => tournament.game_token_id === metaData.token_id)

      let tokenId = parseInt(metaData.token_id, 16)
      let expires_at = parseInt(metaData.lifecycle.end.Some || 0, 16) * 1000
      let available_at = parseInt(metaData.lifecycle.start.Some || 0, 16) * 1000

      return {
        id: tokenId,
        tokenId,
        playerName: hexToAscii(metaData.player_name),
        expires_at,
        available_at,
        settingsId: metaData.settings_id,
        health: game?.hero_health,
        xp: game?.hero_xp,
        tournament_id: tournament?.tournament_id ? parseInt(tournament?.tournament_id, 16) : null,
        active: game?.hero_health !== 0 && (expires_at === 0 || expires_at > Date.now()),
        gameStarted: Boolean(game?.hero_xp),
        eternumQuest: metaData.minted_by.toLowerCase() === ETERNUM_QUEST_ADDRESS,
      }
    })

    return games
  } catch (ex) {
    return []
  }
}

export async function getSettingsMetadata(settings_ids) {
  const document = gql`
  {
    ${NS_SHORT}GameSettingsMetadataModels(where:{settings_idIN:[${settings_ids}]}) {
      edges {
        node {
          settings_id
          name
          description
        }
      }
    }
  }
  `

  const res = await request(GQL_ENDPOINT, document);

  return res?.[`${NS_SHORT}GameSettingsMetadataModels`]?.edges.map(edge => edge.node);
}

export async function getActiveTournaments() {
  try {
    const currentTimeHex = Math.floor(Date.now() / 1000).toString(16).padStart(64, '0');

    let url = `${SQL_ENDPOINT}?query=
      SELECT *
      FROM "${TOURNAMENT_NS}-Tournament"
      WHERE 
        "game_config.address" = "${GAME_ADDRESS.replace(/^0x+/, "0x0")}" AND
        "schedule.game.end" > "0x${currentTimeHex}"
      LIMIT 10000`

    const response = await fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json"
      }
    });

    const data = await response.json();
    return data.map(tournament => ({
      id: parseInt(tournament.id, 16),
      name: hexToAscii(tournament['metadata.name']).replace(/^\0+/, ''),
      description: tournament['metadata.description'],
      start: parseInt(tournament['schedule.game.start'] ?? 0, 16),
      end: parseInt(tournament['schedule.game.end'] ?? 0, 16),
      entryFee: parseInt(tournament['entry_fee.Some.amount'] ?? 0, 16),
      entryFeeDistribution: tournament['entry_fee.Some.distribution'] ?? [],
      submissionPeriod: parseInt(tournament['schedule.submission_duration'] ?? 0, 16)
    }));
  } catch (ex) {
    console.error("Error fetching active tournaments:", ex);
    return [];
  }
}

export async function getTournamentScores(tournament_id) {
  const data = await getTournamentRegistrations(tournament_id)
  let gameIds = data.map(tokenId => `"${tokenId.toString()}"`);
  let leaderboardSize = 10;

  try {
    const document = gql`
    {
      ${NS_SHORT}GameModels (where: {game_idIN:[${gameIds}]}, order:{field:HERO_XP, direction:DESC}, limit:${leaderboardSize}) {
        edges {
          node {
            game_id,
            hero_xp
          }
        }
      }
    }
  `
    const res = await request(GQL_ENDPOINT, document);

    return res?.[`${NS_SHORT}GameModels`]?.edges.map(edge => edge.node.game_id);
  } catch (ex) {
    console.log(ex)
  }
}

export async function getCardDetails(card_ids) {
  let cardIds = card_ids.map(cardId => `"${cardId.toString()}"`);

  const document = gql`
  {
    ${NS_SHORT}CardModels(limit:1000, where:{idIN:[${cardIds}]}) {
      edges {
        node {
          id
          name
          rarity
          cost
          category
        }
      }
    }
    ${NS_SHORT}CreatureCardModels(limit:1000, where:{idIN:[${cardIds}]}) {
      edges {
        node {
          id
          attack
          health
          card_type
          play_effect {
            modifier {
              _type
              value
              value_type
              requirement
            }
            bonus {
              value
              requirement
            }
          }
          attack_effect {
            modifier {
              _type
              value
              value_type
              requirement
            }
            bonus {
              value
              requirement
            }
          }
          death_effect {
            modifier {
              _type
              value
              value_type
              requirement
            }
            bonus {
              value
              requirement
            }
          }
        }
      }
    }
    ${NS_SHORT}SpellCardModels(limit:1000, where:{idIN:[${cardIds}]}) {
      edges {
        node {
          id
          card_type
          effect {
            modifier {
              _type
              value_type
              value
              requirement
            }
            bonus {
              value
              requirement
            }
          }
          extra_effect {
            modifier {
              _type
              value_type
              value
              requirement
            }
            bonus {
              value
              requirement
            }
          }
        }
      }
    }
  }
  `

  const res = await request(GQL_ENDPOINT, document);

  // Get base card data
  const cards = res?.[`${NS_SHORT}CardModels`]?.edges.map(edge => edge.node) || [];
  const creatureCards = res?.[`${NS_SHORT}CreatureCardModels`]?.edges.map(edge => edge.node) || [];
  const spellCards = res?.[`${NS_SHORT}SpellCardModels`]?.edges.map(edge => edge.node) || [];

  const cardDetailsList = cards.map(card => {
    const cardId = parseInt(card.id, 16);
    let details = {};

    // Check if this is a creature card
    if (card.category === 1) {
      const creature = creatureCards.find(c => c.id === card.id);
      if (creature) {
        details = {
          category: types.CREATURE,
          attack: creature.attack,
          health: creature.health,
          cardType: cardTypes[creature.card_type],
          playEffect: formatCardEffect(creature.play_effect),
          deathEffect: formatCardEffect(creature.death_effect),
          attackEffect: formatCardEffect(creature.attack_effect)
        };
      }
    }
    // Check if this is a spell card
    else if (card.category === 2) {
      const spell = spellCards.find(s => s.id === card.id);
      if (spell) {
        details = {
          category: types.SPELL,
          cardType: cardTypes[spell.card_type],
          effect: formatCardEffect(spell.effect),
          extraEffect: formatCardEffect(spell.extra_effect)
        };
      }
    }

    return {
      cardId,
      name: hexToAscii(card.name),
      rarity: rarities[card.rarity],
      cost: card.cost,
      ...details
    };
  });

  return cardDetailsList;
}

export async function getTokenMetadata(game_id) {
  const document = gql`
  {
    ${NS_SHORT}TokenMetadataModels(where:{token_id:"${game_id}"}) {
      edges {
        node {
          token_id
          player_name
          settings_id
          minted_by
          lifecycle {
            start {
              Some
            }
            end {
              Some
            }
          }
        }
      }
    }
    ${NS_SHORT}GameModels (where:{
      game_id:"${game_id}"
    }) {
      edges {
        node {
          game_id,
          state,

          hero_health,
          hero_xp,
          monsters_slain,
          
          map_level,
          map_depth,
          last_node_id
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document);
  const metadata = res?.[`${NS_SHORT}TokenMetadataModels`]?.edges[0]?.node;
  const game = res?.[`${NS_SHORT}GameModels`]?.edges[0]?.node;

  if (!metadata) return null;

  let tokenId = parseInt(metadata.token_id, 16)

  return {
    id: tokenId,
    tokenId,
    playerName: hexToAscii(metadata.player_name),
    settingsId: metadata.settings_id,
    expires_at: parseInt(metadata.lifecycle.end.Some || 0, 16) * 1000,
    available_at: parseInt(metadata.lifecycle.start.Some || 0, 16) * 1000,
    active: game?.hero_health !== 0,
    gameStarted: Boolean(game?.hero_xp),
    eternumQuest: metadata.minted_by.toLowerCase() === ETERNUM_QUEST_ADDRESS,
  };
}

export async function getRecommendedSettings() {
  try {
    let url = `${SQL_ENDPOINT}?query=
      SELECT settings_id, COUNT(*) as usage_count
      FROM "${NS}-TokenMetadata"
      GROUP BY settings_id
      ORDER BY usage_count DESC, settings_id ASC
      LIMIT 50`;

    const response = await fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json"
      }
    });

    const data = await response.json();
    // Filter out settings_id 0 if it exists and add it to the beginning
    const filteredData = data.filter(item => item.settings_id !== 0);
    const topSettingsIds = [0, ...filteredData.map(item => item.settings_id)];

    return await getSettingsList(null, topSettingsIds);
  } catch (error) {
    console.error("Error fetching recommended settings:", error);
    return [];
  }
}

export async function getSettingsList(address = null, ids = null) {
  let whereClause = [];

  if (address) {
    whereClause.push(`metadata.created_by = "${address}"`);
  }

  if (!address && ids && ids.length > 0) {
    const idsFormatted = ids.join(',');
    whereClause.push(`settings.settings_id IN (${idsFormatted})`);
  }

  const whereStatement = whereClause.length > 0
    ? `WHERE ${whereClause.join(' AND ')}`
    : '';

  let url = `${SQL_ENDPOINT}?query=
    SELECT *
    FROM 
      "${NS}-GameSettingsMetadata" as metadata
    JOIN 
      "${NS}-GameSettings" as settings
    ON 
      metadata.settings_id = settings.settings_id
    ${whereStatement}
    ORDER BY settings_id ASC
    LIMIT 1000`;
  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json"
      }
    });

    const data = await response.json();
    let results = data.map(item => ({
      settings_id: item.settings_id,
      name: hexToAscii(item.name).replace(/^\0+/, ''),
      description: item.description,
      created_by: item.created_by,
      starting_health: item.starting_health,
      persistent_health: item.persistent_health,
      possible_branches: item["map.possible_branches"],
      level_depth: item["map.level_depth"],
      enemy_attack_min: item["map.enemy_attack_min"],
      enemy_attack_max: item["map.enemy_attack_max"],
      enemy_health_min: item["map.enemy_health_min"],
      enemy_health_max: item["map.enemy_health_max"],
      enemy_attack_scaling: item["map.enemy_attack_scaling"],
      enemy_health_scaling: item["map.enemy_health_scaling"],
      start_energy: item["battle.start_energy"],
      start_hand_size: item["battle.start_hand_size"],
      max_energy: item["battle.max_energy"],
      max_hand_size: item["battle.max_hand_size"],
      draw_amount: item["battle.draw_amount"],
      auto_draft: Boolean(item["draft.auto_draft"]),
      draft_size: item["draft.draft_size"],
      card_ids: JSON.parse(item["draft.card_ids"]).map(cardId => Number(cardId)),
      card_rarity_weights: {
        common: item["draft.card_rarity_weights.common"],
        uncommon: item["draft.card_rarity_weights.uncommon"],
        rare: item["draft.card_rarity_weights.rare"],
        epic: item["draft.card_rarity_weights.epic"],
        legendary: item["draft.card_rarity_weights.legendary"]
      }
    }));

    // Sort by the order of input IDs if provided
    if (ids && ids.length > 0) {
      results.sort((a, b) => ids.indexOf(a.settings_id) - ids.indexOf(b.settings_id));
    }

    return results;
  } catch (error) {
    console.error("Error fetching settings list:", error);
    return [];
  }
}