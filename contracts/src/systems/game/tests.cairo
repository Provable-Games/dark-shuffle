use darkshuffle::models::battle::{Battle, BattleResources};
use darkshuffle::models::card::{Card, CreatureCard};
use darkshuffle::models::draft::Draft;
use darkshuffle::models::game::{Game, GameOwnerTrait, GameState};
use darkshuffle::models::map::Map;
use darkshuffle::systems::game::contracts::{IGameSystemsDispatcher, IGameSystemsDispatcherTrait, game_systems};
use darkshuffle::utils::cards::CardUtilsImpl;
use darkshuffle::utils::testing::general::{
    create_battle, create_battle_resources, create_draft, create_game, create_map, mint_game_token,
};
use darkshuffle::utils::testing::systems::{deploy_game_systems};
use darkshuffle::utils::testing::world::spawn_darkshuffle;
use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, NamespaceDef, TestResource};
use starknet::{ContractAddress, contract_address_const, testing};

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


#[test]
fn gas_check() {
    setup();
}

#[test]
fn gas_check_game_model() {
    let (mut world, game_id, _) = setup();

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
fn gas_check_read_card() {
    let (mut world, _, _) = setup();

    let card_id = 1;
    let _card: Card = world.read_model(card_id);
    let _creature_card: CreatureCard = world.read_model(card_id);
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

#[test]
#[should_panic(expected: ("Dark Shuffle: Game 1 has already started", 'ENTRYPOINT_FAILED'))]
fn test_cannot_start_game_twice() {
    let (_, game_id, game_systems_dispatcher) = setup();

    // Start the game first time
    game_systems_dispatcher.start_game(game_id);

    // Attempt to start the same game again - should fail
    game_systems_dispatcher.start_game(game_id);
}

#[test]
#[should_panic(expected: ("Dark Shuffle: Caller is not owner of token 1", 'ENTRYPOINT_FAILED'))]
fn test_only_owner_can_start_game() {
    let (_, game_id, game_systems_dispatcher) = setup();

    testing::set_contract_address(contract_address_const::<'not_owner'>());
    testing::set_account_contract_address(contract_address_const::<'not_owner'>());

    // Attempt to start someone else's game - should fail
    game_systems_dispatcher.start_game(game_id);
}

#[test] // 85640107 gas
fn draft_test_pick_card() {
    let (mut world, game_id, game_systems_dispatcher) = setup();
    create_game(ref world, game_id, GameState::Draft);

    create_draft(ref world, game_id, array![1, 2, 3].span(), array![].span());
    game_systems_dispatcher.pick_card(game_id, 1);

    let draft: Draft = world.read_model(game_id);

    assert(draft.cards.len() == 1, 'Selected card is not set');
    assert(*draft.cards.at(0) == 2, 'Wrong card selected');
    assert(*draft.options.at(1) != 2, 'Options not updated');
}

#[test]
fn draft_test_draft_complete() {
    let (mut world, game_id, game_systems_dispatcher) = setup();
    create_game(ref world, game_id, GameState::Draft);

    create_draft(
        ref world,
        game_id,
        array![1, 2, 3].span(),
        array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19].span(),
    );

    game_systems_dispatcher.pick_card(game_id, 1);

    let draft: Draft = world.read_model(game_id);
    let game: Game = world.read_model(game_id);

    assert(draft.cards.len() == 20, 'Draft not complete');
    assert(*draft.options.at(0) == 1, 'Options should not be updated');
    assert(game.state.into() == GameState::Map, 'Game state not set to map');
}


#[test]
fn map_test_generate_tree() {
    let (mut world, game_id, game_systems_dispatcher) = setup();
    create_game(ref world, game_id, GameState::Map);

    game_systems_dispatcher.generate_tree(game_id);

    let game: Game = world.read_model(game_id);
    let map: Map = world.read_model((game.game_id, game.map_level));

    assert(map.seed != 0, 'Map seed is not set');
}

#[test]
fn map_test_select_node() {
    let (mut world, game_id, game_systems_dispatcher) = setup();
    create_game(ref world, game_id, GameState::Map);

    create_map(ref world, game_id, 1, 1000);
    create_draft(
        ref world,
        game_id,
        array![].span(),
        array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].span(),
    );

    let node_id = 1;
    let mut game: Game = world.read_model(game_id);
    game.map_depth = 1;
    game.map_level = 1;
    world.write_model_test(@game);

    game_systems_dispatcher.select_node(game_id, node_id);

    let game: Game = world.read_model(game_id);
    let battle: Battle = world.read_model((game.game_id, game.monsters_slain + 1));
    let battle_resources: BattleResources = world.read_model((battle.battle_id, battle.game_id));

    assert(game.last_node_id == node_id, 'Node id is not set');
    assert(game.state.into() == GameState::Battle, 'Game state not set to battle');
    assert(battle.hero.health > 0, 'Hero health is not set');
    assert(battle.monster.health > 0, 'Monster health is not set');
    assert(battle_resources.hand.len() == 5, 'Hand size is not 5');
    assert(battle_resources.deck.len() == 15, 'Deck size is not 15');
}
