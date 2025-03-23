use darkshuffle::models::battle::{Battle, BattleEffects, BattleResources, Hero, Monster};
use darkshuffle::models::config::{GameSettings, MapSettings};
use darkshuffle::models::draft::Draft;
use darkshuffle::models::game::{Game, GameEffects, GameState};
use darkshuffle::models::map::{Map, MonsterNode};
use darkshuffle::utils::config::ConfigUtilsImpl;
use darkshuffle::utils::hand::HandUtilsImpl;
use darkshuffle::utils::monsters::MonsterUtilsImpl;
use darkshuffle::utils::random;
use dojo::model::ModelStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage};

#[generate_trait]
impl MapUtilsImpl of MapUtilsTrait {
    fn node_available(game: Game, map: Map, node_id: u8, map_settings: MapSettings) -> bool {
        if game.map_depth == 1 && node_id == 1 {
            return true;
        }

        let mut seed = random::LCG(map.seed);
        let sections = random::get_random_number(seed, map_settings.possible_branches);

        let mut is_available = false;
        let mut current_node_id = 1;

        let mut section_index = 0;
        while section_index < sections {
            if map_settings.level_depth == 2 {
                break;
            }

            // Depth 2
            current_node_id += 1;
            if current_node_id == node_id && game.last_node_id == 1 {
                is_available = true;
                break;
            }

            if map_settings.level_depth == 3 {
                section_index += 1;
                continue;
            }

            // Depth 3
            let mut depth_3_count = 1;
            current_node_id += 1;
            if current_node_id == node_id && game.last_node_id == current_node_id - 1 {
                is_available = true;
                break;
            }

            seed = random::LCG(seed);
            if random::get_random_number(seed, map_settings.possible_branches) > 1 {
                depth_3_count += 1;
                current_node_id += 1;
                if current_node_id == node_id && game.last_node_id == current_node_id - 2 {
                    is_available = true;
                    break;
                }
            }

            if map_settings.level_depth == 4 {
                section_index += 1;
                continue;
            }

            // Depth 4
            seed = random::LCG(seed);
            if random::get_random_number(seed, map_settings.possible_branches) > 1 {
                current_node_id += 1;
                if current_node_id == node_id && game.last_node_id == current_node_id - depth_3_count {
                    is_available = true;
                    break;
                }

                current_node_id += 1;
                if current_node_id == node_id && game.last_node_id == current_node_id - 2 {
                    is_available = true;
                    break;
                }
            } else {
                current_node_id += 1;
                if current_node_id == node_id
                    && (game.last_node_id == current_node_id
                        - 1 || game.last_node_id == current_node_id
                        - depth_3_count) {
                    is_available = true;
                    break;
                }
            }

            section_index += 1;
        };

        current_node_id += 1;

        if is_available || (current_node_id == node_id && game.map_depth == map_settings.level_depth) {
            true
        } else {
            false
        }
    }

    fn get_monster_node(map: Map, node_id: u8, map_settings: MapSettings) -> MonsterNode {
        let mut seed = map.seed;
        let mut LCG_iterations = 0;

        while LCG_iterations < node_id {
            seed = random::LCG(seed);
            LCG_iterations += 1;
        };

        let mut monster_range = 0;
        if map.level < 5 {
            monster_range = 75 - (15 * map.level);
        }

        let monster_id = random::get_random_number(seed, 75 - monster_range) + monster_range;

        seed = random::LCG(seed);
        let mut attack = random::get_random_number(seed, map_settings.enemy_attack_max - map_settings.enemy_attack_min) + map_settings.enemy_attack_min;
        attack += (map.level - 1) * map_settings.enemy_attack_scaling;

        seed = random::LCG(seed);
        let mut health = random::get_random_number(seed, map_settings.enemy_health_max - map_settings.enemy_health_min) + map_settings.enemy_health_min;
        health += (map.level - 1) * map_settings.enemy_health_scaling;

        MonsterNode { monster_id, attack, health }
    }

    fn start_battle(ref world: WorldStorage, ref game: Game, monster: MonsterNode, seed: u128) {
        let draft: Draft = world.read_model(game.game_id);
        let game_effects: GameEffects = world.read_model(game.game_id);
        let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, game.game_id);

        game.state = GameState::Battle.into();

        let battle = Battle {
            battle_id: game.monsters_slain + 1,
            game_id: game.game_id,
            round: 1,
            hero: Hero {
                health: game.hero_health, energy: game_settings.battle.start_energy + game_effects.start_bonus_energy,
            },
            monster: Monster { monster_id: monster.monster_id, attack: monster.attack, health: monster.health },
            battle_effects: BattleEffects {
                enemy_marks: 0,
                hero_dmg_reduction: 0,
                next_hunter_attack_bonus: 0,
                next_hunter_health_bonus: 0,
                next_brute_attack_bonus: 0,
                next_brute_health_bonus: 0,
                next_magical_attack_bonus: 0,
                next_magical_health_bonus: 0,
            },
        };

        let mut battle_resources: BattleResources = BattleResources {
            battle_id: battle.battle_id,
            game_id: battle.game_id,
            hand: array![].span(),
            deck: draft.cards,
            board: array![].span(),
        };

        HandUtilsImpl::draw_cards(
            ref battle_resources, game_settings.battle.start_hand_size, game_settings.battle.max_hand_size, seed,
        );

        world.write_model(@battle);
        world.write_model(@battle_resources);
    }
}
