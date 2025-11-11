import { getEntityIdFromKeys, hexToAscii } from "@dojoengine/utils";
import { gql, request } from 'graphql-request';
import { useDynamicConnector } from "../contexts/starknet";
import { cardTypes, formatCardEffect, rarities, types } from "../helpers/cards";
import { get_short_namespace } from '../helpers/components';
import { delay } from "../helpers/utilities";
import { addAddressPadding } from "starknet";

export const useIndexer = () => {
  const { currentNetworkConfig } = useDynamicConnector();

  let NS = currentNetworkConfig.namespace;
  let NS_SHORT = get_short_namespace(NS);
  let GQL_ENDPOINT = currentNetworkConfig.toriiUrl + "/graphql"
  let SQL_ENDPOINT = currentNetworkConfig.toriiUrl + "/sql"

  const getSettings = async (settings_id) => {
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

  const getActiveGame = async (game_id, retry = 0) => {
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

  const getDraft = async (game_id) => {
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

  const getGameEffects = async (game_id) => {
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

  const getMap = async (game_id, level) => {
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

  const getBattleState = async (battle_id, game_id) => {
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

  const getGameTxs = async (game_id) => {
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

  const populateGameTokens = async (gamesData) => {
    const formattedTokenIds = gamesData.map(
      (game) => `"${addAddressPadding(game.token_id.toString(16))}"`
    );

    const document = gql`
    {
      ${NS_SHORT}GameModels (limit:10000, where:{
        game_idIN:[${formattedTokenIds}]}
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
      let gameEvents = res?.[`${NS_SHORT}GameModels`]?.edges.map(edge => edge.node) ?? []

      let games = gamesData.map((game) => {
        let gameData = gameEvents.find(
          (event) =>
            parseInt(event.game_id, 16) === game.token_id
        );

        let tokenId = game.token_id;
        let expiresAt = (game.lifecycle.end || 0) * 1000;
        let availableAt = (game.lifecycle.start || 0) * 1000;

        return {
          id: tokenId,
          tokenId,
          playerName: game.player_name,
          settingsId: game.settings_id,
          expiresAt,
          availableAt,
          health: gameData?.hero_health,
          xp: gameData?.hero_xp,
          active: gameData?.hero_health !== 0 && (expiresAt === 0 || expiresAt > Date.now()),
          gameStarted: Boolean(gameData?.hero_xp),
        }
      })

      return games
    } catch (ex) {
      return []
    }
  }

  const getSettingsMetadata = async (settings_ids) => {
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

  const getCardDetails = async (card_ids) => {
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

  const getRecommendedSettings = async () => {
    try {
      let url = `${currentNetworkConfig.toriiUrl}/sql?query=
          SELECT settings_id, COUNT(*) as usage_count
          FROM "relayer_0_0_1-TokenMetadataUpdate"
          GROUP BY settings_id
          ORDER BY usage_count DESC, settings_id ASC
          LIMIT 50`;

      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      const data = await response.json();
      // Filter out settings_id 0 if it exists and add it to the beginning
      const filteredData = data.filter(item => item.settings_id !== 0);
      const topSettingsIds = [
        0,
        ...filteredData.map(item => item.settings_id),
      ];

      return await getSettingsList(null, topSettingsIds);
    } catch (error) {
      console.error("Error fetching recommended settings:", error);
      return [];
    }
  }

  const getSettingsList = async (address = null, ids = null) => {
    let whereClause = [];

    if (address) {
      whereClause.push(`metadata.created_by = "${addAddressPadding(address)}"`);
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

  return {
    getSettings,
    getActiveGame,
    getDraft,
    getGameEffects,
    getMap,
    getBattleState,
    getGameTxs,
    populateGameTokens,
    getSettingsMetadata,
    getCardDetails,
    getSettingsList,
    getRecommendedSettings,
  }
}