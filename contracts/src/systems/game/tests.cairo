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
    let (mut world, game_systems_dispatcher) = spawn_darkshuffle();
    let settings_id = 0;
    let game_id = mint_game_token(
        world,
        game_systems_dispatcher.contract_address,
        'player1',
        settings_id,
        Option::None,
        Option::None,
        contract_address_const::<'player1'>(),
    );
    (world, game_id, game_systems_dispatcher)
}


#[test] // 93743705 gas
fn gas_check() {
    let (mut world, game_id, game_systems_dispatcher) = setup();
}

#[test]  // 1284384 with introspectpacked, 2593706 without
fn gas_check_game_model() {
    let (mut world, game_id, game_systems_dispatcher) = setup();

    let game = Game {
        game_id,
        state: 1,
        hero_health: 50,
        hero_xp: 1,
        monsters_slain: 0,
        map_level: 0,
        map_depth: 6,
        last_node_id: 0,
        action_count: 0,
    };

    world.write_model(@game);
}

#[test]
fn game_test_start_game() {
    let (mut world, game_id, game_systems_dispatcher) = setup();

    game_systems_dispatcher.start_game(game_id);

    let game: Game = world.read_model(game_id);
    let draft: Draft = world.read_model(game_id);

    assert(game.exists(), 'Game not created');
    assert(game.state.into() == GameState::Draft, 'Game state not set to draft');
    assert(draft.options.len() > 0, 'Draft options not set');
}
