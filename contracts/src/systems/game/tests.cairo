use darkshuffle::models::battle::{Battle};
use darkshuffle::models::draft::{Draft};
use darkshuffle::models::game::{Game, GameState, GameFixedData, GameOwnerTrait};
use darkshuffle::systems::game::contracts::{game_systems, IGameSystemsDispatcher, IGameSystemsDispatcherTrait};

use darkshuffle::utils::testing::{
    world::spawn_darkshuffle, systems::{deploy_system, deploy_game_systems},
    general::{create_default_settings, mint_game_token},
};
use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{NamespaceDef, TestResource, ContractDefTrait};

use starknet::{ContractAddress, contract_address_const};

fn setup() -> (WorldStorage, u64, IGameSystemsDispatcher) {
    let mut world = spawn_darkshuffle();
    let game_systems_dispatcher = deploy_game_systems(ref world);

    let game_id = 1;
    let settings_id = create_default_settings(ref world);

    mint_game_token(ref world, game_id, settings_id);

    (world, game_id, game_systems_dispatcher)
}

#[test] // 83761896 gas
fn game_test_start_game() {
    let (mut world, game_id, game_systems_dispatcher) = setup();

    game_systems_dispatcher.start_game(game_id, 'Test');

    let game_fixed_data: GameFixedData = world.read_model(game_id);
    let game: Game = world.read_model(game_id);
    let draft: Draft = world.read_model(game_id);

    assert(game.exists(), 'Game not created');
    assert(game_fixed_data.player_name == 'Test', 'Player name not set');
    assert(game.state == GameState::Draft, 'Game state not set to draft');
    assert(draft.options.len() > 0, 'Draft options not set');
}
