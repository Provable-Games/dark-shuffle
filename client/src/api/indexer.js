import { getEntityIdFromKeys, hexToAscii } from "@dojoengine/utils";
import { gql, request } from 'graphql-request';
import { dojoConfig } from '../../dojo.config';
import { get_short_namespace } from '../helpers/components';
import { getContractByName } from "@dojoengine/core";

let NS = dojoConfig.namespace;
let NS_SHORT = get_short_namespace(NS);
let GAME_ADDRESS = getContractByName(dojoConfig.manifest, dojoConfig.namespace, "game_systems")?.address
let GQL_ENDPOINT = dojoConfig.toriiUrl + "/graphql"

let TOURNAMENT_NS = dojoConfig.tournamentNamespace;
let TOURNAMENT_NS_SHORT = get_short_namespace(TOURNAMENT_NS);

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

  const res = await request(GQL_ENDPOINT, document)

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

  const res = await request(GQL_ENDPOINT, document)

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

  const res = await request(GQL_ENDPOINT, document)

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

  const res = await request(GQL_ENDPOINT, document);

  const result = {
    battle: res?.entity.models.find(model => model.hero),
    board: res?.entity.models.find(model => model.creature1)
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
  const document = gql`
  {
    tokenBalances(accountAddress:"${accountAddress}", limit:10000) {
      edges {
        node {
        tokenMetadata {
          ... on ERC721__Token {
              contractAddress
              tokenId
            }
          }
        }
      }
    }
  }
  `

  const res = await request(GQL_ENDPOINT, document);

  return res?.tokenBalances?.edges.map(edge => edge.node.tokenMetadata).filter(token => token.contractAddress === GAME_ADDRESS);
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

    ${TOURNAMENT_NS_SHORT}RegistrationModels (limit:10000, where:{
      game_token_idIN:[${tokenIds}]}
    ){
      edges {
        node {
          tournament_id
          game_token_id
        }
      }
    }
  }
  `

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
        settingsId: parseInt(metaData.settings_id, 16),
        health: game?.hero_health,
        xp: game?.hero_xp,
        tournament_id: parseInt(tournament?.tournament_id, 16),
        active: game?.hero_health !== 0 && (expires_at === 0 || expires_at > Date.now())
      }
    })

    return games
  } catch (ex) {
    return []
  }
}

export async function getActiveTournaments() {
  const document = gql`
  {
    ${TOURNAMENT_NS_SHORT}TournamentModels(limit:10000) {
      edges {
        node {
          id,
          schedule {
            game {
              start,
              end
            }
          },
          metadata {
            name,
            description,
          },
          game_config {
            settings_id
            address
          },
          entry_fee {
            Some {
              amount
            }
          }
        }
      }
    }
  }`

  const res = await request(GQL_ENDPOINT, document)
  let tournaments = res?.[`${TOURNAMENT_NS_SHORT}TournamentModels`]?.edges.map(edge => edge.node)
  return tournaments.filter(tournament => tournament.game_config.address === GAME_ADDRESS.toLowerCase() && parseInt(tournament.schedule.game.end, 16) * 1000 > Date.now())
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