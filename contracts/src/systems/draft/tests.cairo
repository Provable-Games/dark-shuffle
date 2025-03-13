use darkshuffle::models::battle::{Battle};
use darkshuffle::models::draft::{Draft};
use darkshuffle::models::game::{Game, GameState};
use darkshuffle::systems::draft::contracts::{IDraftSystemsDispatcher, IDraftSystemsDispatcherTrait, draft_systems};

use darkshuffle::utils::testing::{
    general::{create_draft, create_game, mint_game_token},
    systems::{deploy_draft_systems, deploy_system}, world::spawn_darkshuffle,
};
use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, NamespaceDef, TestResource};

use starknet::{ContractAddress, contract_address_const};

fn setup() -> (WorldStorage, u64, IDraftSystemsDispatcher) {
    let (mut world, game_systems_dispatcher) = spawn_darkshuffle();
    let draft_systems_dispatcher = deploy_draft_systems(ref world);

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

    create_game(ref world, game_id, GameState::Draft);

    (world, game_id, draft_systems_dispatcher)
}

#[test] // 85640107 gas
fn draft_test_pick_card() {
    let (mut world, game_id, draft_systems_dispatcher) = setup();

    create_draft(ref world, game_id, array![1, 2, 3].span(), array![].span());
    draft_systems_dispatcher.pick_card(game_id, 1);

    let draft: Draft = world.read_model(game_id);

    assert(draft.cards.len() == 1, 'Selected card is not set');
    assert(*draft.cards.at(0) == 2, 'Wrong card selected');
    assert(*draft.options.at(1) != 2, 'Options not updated');
}

#[test] // 105444654 gas
fn draft_test_draft_complete() {
    let (mut world, game_id, draft_systems_dispatcher) = setup();

    create_draft(
        ref world,
        game_id,
        array![1, 2, 3].span(),
        array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19].span(),
    );

    draft_systems_dispatcher.pick_card(game_id, 1);

    let draft: Draft = world.read_model(game_id);
    let game: Game = world.read_model(game_id);

    assert(draft.cards.len() == 20, 'Draft not complete');
    assert(*draft.options.at(0) == 1, 'Options should not be updated');
    assert(game.state.into() == GameState::Map, 'Game state not set to map');
}
