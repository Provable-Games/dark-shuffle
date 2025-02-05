use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{NamespaceDef, TestResource, ContractDefTrait};

use starknet::{ContractAddress, contract_address_const};

use darkshuffle::models::battle::{Battle};
use darkshuffle::models::game::{Game, GameState};
use darkshuffle::models::draft::{Draft};

use darkshuffle::utils::testing::{
    world::spawn_darkshuffle, systems::{deploy_system, deploy_draft_systems, deploy_map_systems, deploy_game_systems, deploy_battle_systems},
    general::{mint_game_token, create_game, create_draft, create_custom_settings, create_map, create_battle},
};
use darkshuffle::systems::draft::contracts::{draft_systems, IDraftSystemsDispatcher, IDraftSystemsDispatcherTrait};
use darkshuffle::systems::map::contracts::{map_systems, IMapSystemsDispatcher, IMapSystemsDispatcherTrait};
use darkshuffle::systems::game::contracts::{game_systems, IGameSystemsDispatcher, IGameSystemsDispatcherTrait};
use darkshuffle::systems::battle::contracts::{battle_systems, IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait};

const START_HEALTH: u8 = 10;
const START_ENERGY: u8 = 5;
const START_HAND_SIZE: u8 = 1;
const MAX_ENERGY: u8 = 15;
const MAX_HAND_SIZE: u8 = 2;

fn setup() -> (WorldStorage, u128) {
    let mut world = spawn_darkshuffle();

    let draft_size = 5;

    let settings_id = create_custom_settings(
        ref world,
        START_HEALTH,
        START_ENERGY,
        START_HAND_SIZE,
        draft_size,
        MAX_ENERGY,
        MAX_HAND_SIZE,
        true
    );

    let game_id = 1;
    mint_game_token(ref world, game_id, settings_id);

    (world, game_id)
}

#[test] // 106622001 gas
fn config_test_draft_size() {
    let (mut world, game_id) = setup();
    let draft_systems_dispatcher = deploy_draft_systems(ref world);

    create_game(ref world, game_id, GameState::Draft);
    create_draft(ref world, game_id, array![1, 2, 3].span(), array![1, 2, 3].span());
    draft_systems_dispatcher.pick_card(game_id, 1);

    let draft: Draft = world.read_model(game_id);
    assert(draft.cards.len() == 4, 'Selected card is not set');

    draft_systems_dispatcher.pick_card(game_id, 0);

    let draft: Draft = world.read_model(game_id);
    let game: Game = world.read_model(game_id);

    assert(draft.cards.len() == 5, 'Selected card is not set');
    assert(game.state == GameState::Map, 'Game state not set to map');
}

#[test] // 108082996 gas
fn config_test_start_battle() {
    let (mut world, game_id) = setup();
    let map_systems_dispatcher = deploy_map_systems(ref world);
    let game_systems_dispatcher = deploy_game_systems(ref world);

    game_systems_dispatcher.start_game(game_id, 'Test');
    create_map(ref world, game_id, 1, 1000);
    create_draft(ref world, game_id, array![].span(), array![1, 2, 3, 4, 5].span());

    let mut game: Game = world.read_model(game_id);
    game.map_depth = 1;
    game.map_level = 1;
    game.state = GameState::Map;
    world.write_model_test(@game);

    let node_id = 1;
    map_systems_dispatcher.select_node(game_id, node_id);

    let game: Game = world.read_model(game_id);
    let battle: Battle = world.read_model((game.game_id, game.monsters_slain + 1));

    assert(battle.hero.health == START_HEALTH, 'Hero health incorrect');
    assert(battle.hero.energy == START_ENERGY, 'Hero energy incorrect');
    assert(battle.hand.len() == START_HAND_SIZE.into(), 'Hand size incorrect');
}

#[test] // 106246647 gas
fn config_test_max_energy_and_hand_size() {
    let (mut world, game_id) = setup();
    let battle_systems_dispatcher = deploy_battle_systems(ref world);

    let hero_health = 50;
    let monster_attack = 3;

    let battle_id = create_battle(
        ref world,
        game_id,
        MAX_ENERGY - 1,
        hero_health,
        255,
        75,
        monster_attack,
        10,
        array![1, 2].span(),
        array![1,2,3,4,5].span()
    );

    battle_systems_dispatcher.battle_actions(game_id, battle_id, array![array![1].span()].span());

    let battle: Battle = world.read_model((battle_id, game_id));

    assert(battle.hero.energy == MAX_ENERGY, 'Energy not increased');
    assert(battle.hand.len() == MAX_HAND_SIZE.into(), 'Hand size incorrect');
}