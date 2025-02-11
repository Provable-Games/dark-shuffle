use darkshuffle::models::battle::{Battle};
use darkshuffle::models::draft::{Draft};
use darkshuffle::models::game::{Game, GameOwnerTrait, GameState};
use darkshuffle::systems::game::contracts::{IGameSystemsDispatcher, IGameSystemsDispatcherTrait, game_systems};

use darkshuffle::utils::testing::{
    general::{create_default_settings, mint_game_token}, systems::{deploy_game_systems, deploy_system},
    world::spawn_darkshuffle,
};
use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, NamespaceDef, TestResource};

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

    game_systems_dispatcher.start_game(game_id);

    let game: Game = world.read_model(game_id);
    let draft: Draft = world.read_model(game_id);

    assert(game.exists(), 'Game not created');
    assert(game.state == GameState::Draft, 'Game state not set to draft');
    assert(draft.options.len() > 0, 'Draft options not set');
}
