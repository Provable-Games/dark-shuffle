use darkshuffle::models::battle::{Battle, BattleResources, Card, Creature};
use darkshuffle::models::game::{Game, GameState};
use darkshuffle::systems::battle::contracts::{IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait, battle_systems};
use darkshuffle::utils::cards::CardUtilsImpl;

use darkshuffle::utils::testing::{
    general::{create_battle, create_battle_resources, create_game, mint_game_token},
    systems::{deploy_battle_systems, deploy_system}, world::spawn_darkshuffle,
};
use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, NamespaceDef, TestResource};

use starknet::{ContractAddress, contract_address_const};

fn setup() -> (WorldStorage, u64, IBattleSystemsDispatcher) {
    let (mut world, game_systems_dispatcher) = spawn_darkshuffle();
    let battle_systems_dispatcher = deploy_battle_systems(ref world);

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
    create_game(ref world, game_id, GameState::Battle);

    (world, game_id, battle_systems_dispatcher)
}

#[test] // 120812980 gas
fn battle_test_end_turn() {
    let (mut world, game_id, battle_systems_dispatcher) = setup();

    let hero_health = 50;
    let monster_attack = 3;

    let battle_id = create_battle(ref world, game_id, 1, hero_health, 255, 75, monster_attack, 10);

    create_battle_resources(
        ref world,
        game_id,
        array![1, 2, 3].span(),
        array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].span(),
    );

    battle_systems_dispatcher.battle_actions(game_id, battle_id, array![array![1].span()].span());

    let battle: Battle = world.read_model((battle_id, game_id));
    let battle_resources: BattleResources = world.read_model((battle_id, game_id));

    assert(battle.round == 2, 'Round not incremented');
    assert(battle.hero.energy == battle.round, 'Energy not increased');
    assert(battle_resources.hand.len() == 4, 'No cards drawn');
    assert(battle.hero.health == hero_health - monster_attack, 'Hero health not reduced');
}

#[test] // 124361191 gas
fn battle_test_summon_creature() {
    let (mut world, game_id, battle_systems_dispatcher) = setup();

    let card_index = 0;
    let card: Card = CardUtilsImpl::get_card(world, game_id, card_index);
    let battle_id = create_battle(ref world, game_id, 1, 50, card.cost, 1, 0, 100);

    create_battle_resources(
        ref world,
        game_id,
        array![card_index].span(),
        array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].span(),
    );

    battle_systems_dispatcher
        .battle_actions(game_id, battle_id, array![array![0, card_index].span(), array![1].span()].span());

    let battle_resources: BattleResources = world.read_model((battle_id, game_id));

    assert(*battle_resources.board.at(0).card_index == card_index, 'Creature card index not set');
    assert(battle_resources.hand.len() == 1, 'Card not removed from hand');

    let battle: Battle = world.read_model((battle_id, game_id));
    assert(battle.monster.health != 100, 'Monster health not reduced');
}