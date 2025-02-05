use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{NamespaceDef, TestResource, ContractDefTrait};

use starknet::{ContractAddress, contract_address_const};

use darkshuffle::models::battle::{Battle};
use darkshuffle::models::game::{Game, GameState};
use darkshuffle::models::draft::{Draft};

use darkshuffle::utils::testing::{
    world::spawn_darkshuffle, systems::{deploy_system, deploy_draft_systems},
    general::{create_default_settings, mint_game_token, create_game, create_draft},
};
use darkshuffle::systems::draft::contracts::{draft_systems, IDraftSystemsDispatcher, IDraftSystemsDispatcherTrait};

fn setup() -> (WorldStorage, u128, IDraftSystemsDispatcher) {
    let mut world = spawn_darkshuffle();
    let draft_systems_dispatcher = deploy_draft_systems(ref world);

    let game_id = 1;
    let settings_id = create_default_settings(ref world);

    mint_game_token(ref world, game_id, settings_id);
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
        array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19].span()
    );

    draft_systems_dispatcher.pick_card(game_id, 1);

    let draft: Draft = world.read_model(game_id);
    let game: Game = world.read_model(game_id);

    assert(draft.cards.len() == 20, 'Draft not complete');
    assert(*draft.options.at(0) == 1, 'Options should not be updated');
    assert(game.state == GameState::Map, 'Game state not set to map');
}