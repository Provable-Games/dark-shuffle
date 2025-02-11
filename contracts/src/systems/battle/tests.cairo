use darkshuffle::models::battle::{Battle, Board, Card, Creature};
use darkshuffle::models::draft::{Draft};
use darkshuffle::models::game::{Game, GameOwnerTrait, GameState};
use darkshuffle::systems::battle::contracts::{IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait, battle_systems};
use darkshuffle::utils::cards::CardUtilsImpl;

use darkshuffle::utils::testing::{
    general::{create_battle, create_default_settings, create_game, mint_game_token},
    systems::{deploy_battle_systems, deploy_system, deploy_game_systems}, world::spawn_darkshuffle,
};
use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, NamespaceDef, TestResource};

use starknet::{ContractAddress, contract_address_const};

fn setup() -> (WorldStorage, u64, IBattleSystemsDispatcher) {
    let mut world = spawn_darkshuffle();
    let battle_systems_dispatcher = deploy_battle_systems(ref world);
    let settings_id = create_default_settings(ref world);
    let (game_systems_dispatcher, game_component_dispatcher) = deploy_game_systems(ref world);
    let game_id = mint_game_token(
        ref world,
        game_systems_dispatcher.contract_address,
        'player1',
        settings_id,
        0,
        0,
        contract_address_const::<'player1'>()
    );
    create_game(ref world, game_id, GameState::Battle);

    (world, game_id, battle_systems_dispatcher)
}

#[test] // 120812980 gas
fn battle_test_end_turn() {
    let (mut world, game_id, battle_systems_dispatcher) = setup();

    let hero_health = 50;
    let monster_attack = 3;

    let battle_id = create_battle(
        ref world,
        game_id,
        1,
        hero_health,
        255,
        75,
        monster_attack,
        10,
        array![1, 2, 3].span(),
        array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].span(),
    );

    battle_systems_dispatcher.battle_actions(game_id, battle_id, array![array![1].span()].span());

    let battle: Battle = world.read_model((battle_id, game_id));

    assert(battle.round == 2, 'Round not incremented');
    assert(battle.hero.energy == battle.round, 'Energy not increased');
    assert(battle.hand.len() == 4, 'No cards drawn');
    assert(battle.hero.health == hero_health - monster_attack, 'Hero health not reduced');
}

#[test] // 124361191 gas
fn battle_test_summon_creature() {
    let (mut world, game_id, battle_systems_dispatcher) = setup();

    let card: Card = CardUtilsImpl::get_card(1);
    let battle_id = create_battle(
        ref world,
        game_id,
        1,
        50,
        card.cost,
        255,
        0,
        100,
        array![card.card_id].span(),
        array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].span(),
    );

    battle_systems_dispatcher
        .battle_actions(game_id, battle_id, array![array![0, card.card_id].span(), array![1].span()].span());

    let board: Board = world.read_model((battle_id, game_id));
    let battle: Battle = world.read_model((battle_id, game_id));

    assert(board.creature1.card_id == card.card_id, 'Creature card id not set');
    assert(battle.hand.len() == 1, 'Card not removed from hand');
}

#[test] // 125119600 gas
fn battle_test_attack_enemy() {
    let (mut world, game_id, battle_systems_dispatcher) = setup();

    let battle_id = create_battle(
        ref world,
        game_id,
        1,
        50,
        1,
        255,
        3,
        100,
        array![].span(),
        array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].span(),
    );

    let mut board: Board = world.read_model((battle_id, game_id));
    board.creature1 = Creature { card_id: 255, attack: 1, health: 1 };
    world.write_model_test(@board);

    battle_systems_dispatcher.battle_actions(game_id, battle_id, array![array![1].span()].span());

    let board: Board = world.read_model((battle_id, game_id));
    let battle: Battle = world.read_model((battle_id, game_id));

    assert(board.creature1.health == 0, 'Creature health not reduced');
    assert(battle.monster.health == 99, 'Monster health not reduced');
}
