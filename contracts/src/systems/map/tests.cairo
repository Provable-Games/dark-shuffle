use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{NamespaceDef, TestResource, ContractDefTrait};

use starknet::{ContractAddress, contract_address_const};

use darkshuffle::models::battle::{Battle};
use darkshuffle::models::game::{Game, GameState};
use darkshuffle::models::map::{Map};

use darkshuffle::utils::testing::{
    world::spawn_darkshuffle, systems::{deploy_system, deploy_map_systems},
    general::{create_game, create_draft, create_map},
};
use darkshuffle::systems::map::contracts::{map_systems, IMapSystemsDispatcher, IMapSystemsDispatcherTrait};

fn setup() -> (WorldStorage, u128, IMapSystemsDispatcher) {
    let mut world = spawn_darkshuffle();
    let map_systems_dispatcher = deploy_map_systems(ref world);

    let game_id = create_game(ref world, 1, GameState::Map);

    (world, game_id, map_systems_dispatcher)
}

#[test]
#[available_gas(3000000000000)]
fn map_test_generate_tree() {
    let (mut world, game_id, map_systems_dispatcher) = setup();

    map_systems_dispatcher.generate_tree(game_id);

    let game: Game = world.read_model(game_id);
    let map: Map = world.read_model((game.game_id, game.map_level));

    assert(map.seed != 0, 'Map seed is not set');
}

#[test]
#[available_gas(3000000000000)]
fn map_test_select_node() {
    let (mut world, game_id, map_systems_dispatcher) = setup();

    create_map(ref world, game_id, 1, 1000);
    create_draft(ref world, game_id, array![].span(), array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].span());

    let node_id = 1;
    let mut game: Game = world.read_model(game_id);
    game.map_depth = 1;
    game.map_level = 1;
    world.write_model_test(@game);

    map_systems_dispatcher.select_node(game_id, node_id);

    let game: Game = world.read_model(game_id);
    let battle: Battle = world.read_model((game.game_id, game.monsters_slain + 1));

    assert(game.last_node_id == node_id, 'Node id is not set');
    assert(game.state == GameState::Battle, 'Game state not set to battle');
    assert(battle.hero.health > 0, 'Hero health is not set');
    assert(battle.monster.health > 0, 'Monster health is not set');
}