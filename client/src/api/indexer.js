import { getEntityIdFromKeys } from "@dojoengine/utils";
import { gql, request } from 'graphql-request';
import { dojoConfig } from '../../dojo.config';
import { get_short_namespace } from '../helpers/components';

let NS = dojoConfig.namespace;
let NS_SHORT = get_short_namespace();

export async function getTournament(tournament_id) {
  const document = gql`
  {
    tournamentsTournamentModels(where:{id:"${tournament_id}"}) {
      edges {
        node {
          id,
          schedule {
            game {
              start,
              end
            }
          },
          game_config {
            settings_id
          },
          entry_fee {
            Some {
              amount
            }
          }
        }
      }
    }
    tournamentsEntryCountModels(where:{tournament_id:"${tournament_id}"}) {
      edges {
        node {
          count
        }
      }
    }
  }`

  const res = await request(dojoConfig.toriiUrl, document)
  return {
    tournament: res?.tournamentsTournamentModels?.edges[0]?.node,
    entryCount: res?.tournamentsEntryCountModels?.edges[0]?.node?.count || 0
  }
}

export async function getSettings(settings_id) {
  const document = gql`
  {
    ${NS_SHORT}GameSettingsModels(where:{settings_id:${settings_id}}) {
      edges {
        node {
          settings_id,
          start_health,
          start_energy,
          start_hand_size,
          draft_size,
          max_energy,
          max_hand_size,
        }
      }
    }
  }`

  const res = await request(dojoConfig.toriiUrl, document)

  return res?.[`${NS_SHORT}GameSettingsModels`]?.edges[0]?.node
}

export async function getActiveGame(game_id) {
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

  const res = await request(dojoConfig.toriiUrl, document)

  return res?.[`${NS_SHORT}GameModels`]?.edges[0]?.node;
}

export async function getDraft(game_id) {
  const document = gql`
    {
    entity (id:"${getEntityIdFromKeys([BigInt(game_id)])}") {
      models {
        ... on ${NS}_Draft {
          game_id,
          options,
          cards
        }
      }
    }
  }`

  const res = await request(dojoConfig.toriiUrl, document)

  return res?.entity.models.find(x => x.game_id)
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
          first_creature_cost,
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

  const res = await request(dojoConfig.toriiUrl, document);

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

  const res = await request(dojoConfig.toriiUrl, document);

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

          hand
          deck
          
          battle_effects { 
            enemy_marks
            hero_dmg_reduction
            next_hunter_attack_bonus
            next_hunter_health_bonus
            next_brute_attack_bonus
            next_brute_health_bonus
          }
        }
        ... on ${NS}_Board {
          creature1 {
            card_id,
            attack,
            health,
          }
          creature2 {
            card_id,
            attack,
            health,
          }
          creature3 {
            card_id,
            attack,
            health,
          }
          creature4 {
            card_id,
            attack,
            health,
          }
          creature5 {
            card_id,
            attack,
            health,
          }
          creature6 {
            card_id,
            attack,
            health,
          }
        }
      }
    }
  }`

  const res = await request(dojoConfig.toriiUrl, document);

  const result = {
    battle: res?.entity.models.find(model => model.hero),
    board: res?.entity.models.find(model => model.creature1)
  };

  return result;
}

export async function getLeaderboard(page) {
  let pageSize = 10;

  try {
    const document = gql`
    {
      ${NS_SHORT}GameModels (where: {hero_health: 0}, order:{field:HERO_XP, direction:DESC}, limit:${pageSize}, offset:${pageSize * page}) {
        edges {
          node {
            game_id,
            hero_xp
          }
        }
      }
    }
  `
    const res = await request(dojoConfig.toriiUrl, document);

    return res?.[`${NS_SHORT}GameModels`]?.edges.map(edge => edge.node);
  } catch (ex) {
    console.log(ex)
  }
}

export async function getActiveLeaderboard(page) {
  let pageSize = 10;

  try {
    const document = gql`
    {
      ${NS_SHORT}GameModels (where: {hero_healthGT: 0}, order:{field:HERO_XP, direction:DESC}, limit:${pageSize}, offset:${pageSize * page}) {
        edges {
          node {
            game_id,
            hero_xp
          }
        }
      }
    }
  `
    const res = await request(dojoConfig.toriiUrl, document);

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

  const res = await request(dojoConfig.toriiUrl, document);

  return res?.[`${NS_SHORT}GameActionEventModels`]?.edges.map(edge => edge.node);
}

