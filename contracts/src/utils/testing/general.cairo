use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};

use darkshuffle::constants::{LAST_NODE_DEPTH, WORLD_CONFIG_ID};
use darkshuffle::models::game::{Game, GameState};
use darkshuffle::models::config::{WorldConfig, GameSettings};
use darkshuffle::models::draft::Draft;
use darkshuffle::models::map::Map;

use starknet::{get_caller_address, contract_address_const};

use darkshuffle::utils::testing::systems::{deploy_game_token_mock};
use darkshuffle::utils::testing::mock::gameTokenMock::{IGameTokenMockDispatcher, IGameTokenMockDispatcherTrait};

fn create_game(ref world: WorldStorage, game_id: u128, state: GameState) -> u128 {
    let settings_id = create_default_settings(ref world);

    let game_token_address = deploy_game_token_mock(ref world);

    world.write_model_test(@WorldConfig {
        config_id: 1,
        game_token_address,
        game_count: 0,
    });

    let game_token = IGameTokenMockDispatcher { contract_address: game_token_address };
    game_token.mint(contract_address_const::<'player1'>(), game_id.into(), settings_id);

    world.write_model_test(@Game {
        game_id,
        season_id: 1,
        player_name: 'test',
        state,

        hero_health: 100,
        hero_xp: 1,
        monsters_slain: 0,

        map_level: 0,
        map_depth: LAST_NODE_DEPTH,
        last_node_id: 0,

        action_count: 0,
    });

    game_id
}

fn create_default_settings(ref world: WorldStorage) -> u32 {
    let settings_id = 1;

    world.write_model_test(@GameSettings {
        settings_id,
        start_health: 50,
        start_energy: 1,
        start_hand_size: 5,
        draft_size: 20,
        max_health: 80,
        max_energy: 7,
        max_hand_size: 1,
        include_spells: true,
    });

    settings_id
}

fn create_draft(ref world: WorldStorage, game_id: u128, options: Span<u8>, cards: Span<u8>) {
    world.write_model_test(@Draft {
        game_id,
        options,
        cards,
    });
}

fn create_map(ref world: WorldStorage, game_id: u128, level: u8, seed: u128) {
    world.write_model_test(@Map {
        game_id,
        level,
        seed,
    });
}