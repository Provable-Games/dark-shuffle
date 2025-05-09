use darkshuffle::constants::DEFAULT_SETTINGS::{GET_DEFAULT_WEIGHTS, GET_GENESIS_CARD_IDS};

use darkshuffle::models::battle::{Battle, BattleResources};
use darkshuffle::models::draft::{Draft};
use darkshuffle::models::game::{Game, GameState};
use darkshuffle::systems::battle::contracts::{IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait, battle_systems};
use darkshuffle::systems::game::contracts::{IGameSystemsDispatcher, IGameSystemsDispatcherTrait, game_systems};

use darkshuffle::utils::testing::{
    general::{
        create_battle, create_battle_resources, create_custom_settings, create_draft, create_game, create_map,
        mint_game_token,
    },
    systems::{deploy_battle_systems, deploy_game_systems}, world::spawn_darkshuffle,
};
use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, NamespaceDef, TestResource};

use starknet::{ContractAddress, contract_address_const};

const STARTING_HEALTH: u8 = 10;
const START_ENERGY: u8 = 5;
const START_HAND_SIZE: u8 = 1;
const MAX_ENERGY: u8 = 15;
const MAX_HAND_SIZE: u8 = 2;
const DRAFT_SIZE: u8 = 5;
const DRAW_AMOUNT: u8 = 1;
const AUTO_DRAFT: bool = true;
const PERSISTENT_HEALTH: bool = true;
const POSSIBLE_BRANCHES: u8 = 3;
const LEVEL_DEPTH: u8 = 5;
const ENEMY_ATTACK_MIN: u8 = 2;
const ENEMY_ATTACK_MAX: u8 = 3;
const ENEMY_HEALTH_MIN: u8 = 30;
const ENEMY_HEALTH_MAX: u8 = 50;
const ENEMY_ATTACK_SCALING: u8 = 1;
const ENEMY_HEALTH_SCALING: u8 = 5;

fn setup() -> (WorldStorage, u64, IGameSystemsDispatcher) {
    let (mut world, game_systems_dispatcher) = spawn_darkshuffle();

    let settings_id = create_custom_settings(
        ref world,
        STARTING_HEALTH,
        START_ENERGY,
        START_HAND_SIZE,
        DRAFT_SIZE,
        MAX_ENERGY,
        MAX_HAND_SIZE,
        DRAW_AMOUNT,
        PERSISTENT_HEALTH,
        AUTO_DRAFT,
        GET_GENESIS_CARD_IDS(),
        GET_DEFAULT_WEIGHTS(),
        POSSIBLE_BRANCHES,
        LEVEL_DEPTH,
        ENEMY_ATTACK_MIN,
        ENEMY_ATTACK_MAX,
        ENEMY_HEALTH_MIN,
        ENEMY_HEALTH_MAX,
        ENEMY_ATTACK_SCALING,
        ENEMY_HEALTH_SCALING,
    );

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

#[test] // 106622001 gas
fn config_test_draft_size() {
    let (mut world, game_id, game_systems_dispatcher) = setup();

    create_game(ref world, game_id, GameState::Draft);
    create_draft(ref world, game_id, array![1, 2, 3].span(), array![1, 2, 3].span());
    game_systems_dispatcher.pick_card(game_id, 1);

    let draft: Draft = world.read_model(game_id);
    assert(draft.cards.len() == 4, 'Selected card is not set');

    game_systems_dispatcher.pick_card(game_id, 0);

    let draft: Draft = world.read_model(game_id);
    let game: Game = world.read_model(game_id);

    assert(draft.cards.len() == 5, 'Selected card is not set');
    assert(game.state.into() == GameState::Map, 'Game state not set to map');
}

#[test] // 108082996 gas
fn config_test_start_battle() {
    let (mut world, game_id, game_systems_dispatcher) = setup();

    game_systems_dispatcher.start_game(game_id);
    create_map(ref world, game_id, 1, 1000);
    create_draft(ref world, game_id, array![].span(), array![1, 2, 3, 4, 5].span());

    let mut game: Game = world.read_model(game_id);
    game.map_depth = 1;
    game.map_level = 1;
    game.state = GameState::Map.into();
    world.write_model_test(@game);

    let node_id = 1;
    game_systems_dispatcher.select_node(game_id, node_id);

    let game: Game = world.read_model(game_id);
    let battle: Battle = world.read_model((game.game_id, game.monsters_slain + 1));
    let battle_resources: BattleResources = world.read_model((battle.battle_id, battle.game_id));

    assert(battle.hero.health == STARTING_HEALTH, 'Hero health incorrect');
    assert(battle.hero.energy == START_ENERGY, 'Hero energy incorrect');
    assert(battle_resources.hand.len() == START_HAND_SIZE.into(), 'Hand size incorrect');
}

#[test] // 106246647 gas
fn config_test_max_energy_and_hand_size() {
    let (mut world, game_id, _) = setup();
    let battle_systems_dispatcher = deploy_battle_systems(ref world);

    let hero_health = 50;
    let monster_attack = 3;

    let battle_id = create_battle(ref world, game_id, MAX_ENERGY - 1, hero_health, 255, 75, monster_attack, 10);

    create_battle_resources(ref world, game_id, array![1, 2].span(), array![1, 2, 3, 4, 5].span());

    battle_systems_dispatcher.battle_actions(game_id, battle_id, array![array![1].span()].span());

    let battle: Battle = world.read_model((battle_id, game_id));
    let battle_resources: BattleResources = world.read_model((battle_id, game_id));

    assert(battle.hero.energy == MAX_ENERGY, 'Energy not increased');
    assert(battle_resources.hand.len() == MAX_HAND_SIZE.into(), 'Hand size incorrect');
}
