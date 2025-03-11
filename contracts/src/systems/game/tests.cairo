use darkshuffle::models::battle::Battle;
use darkshuffle::models::card::{Card, CreatureCard};
use darkshuffle::models::draft::Draft;
use darkshuffle::models::game::{Game, GameOwnerTrait, GameState};
use darkshuffle::systems::game::contracts::{IGameSystemsDispatcher, IGameSystemsDispatcherTrait, game_systems};
use darkshuffle::utils::testing::general::mint_game_token;
use darkshuffle::utils::testing::systems::{deploy_game_systems, deploy_system};
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


#[test] // 1276286585 gas
fn gas_check() {
    setup();
}

#[test] // 1277570969 with introspectpacked
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
    let (mut world, game_id, _) = setup();

    let card_id = 1;
    let card: Card = world.read_model(card_id);
    let creature_card: CreatureCard = world.read_model(card_id);
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
