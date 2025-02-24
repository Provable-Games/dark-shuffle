use darkshuffle::constants::{LAST_NODE_DEPTH, WORLD_CONFIG_ID};
use darkshuffle::models::battle::{Battle, BattleEffects, Hero, Monster};
use darkshuffle::models::config::{GameSettings, WorldConfig};
use darkshuffle::models::draft::Draft;
use darkshuffle::models::game::{Game, GameState};
use darkshuffle::models::map::Map;
use darkshuffle::utils::testing::mock::gameTokenMock::{IGameTokenMockDispatcher, IGameTokenMockDispatcherTrait};

use darkshuffle::utils::testing::systems::{deploy_game_token_mock};
use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use starknet::{ContractAddress, contract_address_const, get_caller_address};
use tournaments::components::game::game_component;
use tournaments::components::interfaces::{
    IGameDetails, IGameToken, IGameTokenDispatcher, IGameTokenDispatcherTrait, ISettings,
};

fn mint_game_token(
    world: WorldStorage,
    token_address: ContractAddress,
    player_name: felt252,
    settings_id: u32,
    available_at: Option<u64>,
    expires_at: Option<u64>,
    to: ContractAddress,
) -> u64 {
    let game_systems_dispatcher = IGameTokenDispatcher { contract_address: token_address };
    game_systems_dispatcher.mint(player_name, settings_id, available_at, expires_at, to)
}

fn create_game(ref world: WorldStorage, game_id: u64, state: GameState) {
    world
        .write_model_test(
            @Game {
                game_id,
                state: state.into(),
                hero_health: 100,
                hero_xp: 1,
                monsters_slain: 0,
                map_level: 0,
                map_depth: LAST_NODE_DEPTH,
                last_node_id: 0,
                action_count: 0,
            },
        );
}

fn create_draft(ref world: WorldStorage, game_id: u64, options: Span<u8>, cards: Span<u8>) {
    world.write_model_test(@Draft { game_id, options, cards });
}

fn create_map(ref world: WorldStorage, game_id: u64, level: u8, seed: u128) {
    world.write_model_test(@Map { game_id, level, seed });
}

fn create_default_settings(ref world: WorldStorage) -> u32 {
    let settings_id = 1;

    world
        .write_model_test(
            @GameSettings {
                settings_id,
                start_health: 50,
                start_energy: 1,
                start_hand_size: 5,
                draft_size: 20,
                max_energy: 7,
                max_hand_size: 10,
                include_spells: true,
            },
        );

    settings_id
}

fn create_custom_settings(
    ref world: WorldStorage,
    start_health: u8,
    start_energy: u8,
    start_hand_size: u8,
    draft_size: u8,
    max_energy: u8,
    max_hand_size: u8,
    include_spells: bool,
) -> u32 {
    let settings_id = 99;

    world
        .write_model_test(
            @GameSettings {
                settings_id,
                start_health,
                start_energy,
                start_hand_size,
                draft_size,
                max_energy,
                max_hand_size,
                include_spells,
            },
        );

    settings_id
}

fn create_battle(
    ref world: WorldStorage,
    game_id: u64,
    round: u8,
    hero_health: u8,
    hero_energy: u8,
    monster_id: u8,
    monster_attack: u8,
    monster_health: u8,
) -> u16 {
    let battle_id = 1;

    world
        .write_model_test(
            @Battle {
                battle_id,
                game_id,
                round,
                hero: Hero { health: hero_health, energy: hero_energy },
                monster: Monster { monster_id, attack: monster_attack, health: monster_health },
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
            },
        );

    battle_id
}

fn create_battle_resources(ref world: WorldStorage, game_id: u64, hand: Span<u8>, deck: Span<u8>) {
    world.write_model_test(@BattleResources {
        battle_id: 1,
        game_id,
        hand,
        deck,
        board: array![].span(),
    });
}
