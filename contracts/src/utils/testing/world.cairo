use core::array::{ArrayTrait, SpanTrait};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo_cairo_test::{
    spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef, WorldStorageTestTrait
};
use darkshuffle::constants::{DEFAULT_NS, DEFAULT_NS_STR};
use darkshuffle::models::{
    battle::{m_Battle, m_Board},
    config::{m_WorldConfig, m_GameSettings},
    draft::{m_Draft},
    game::{m_Game, m_GameEffects, m_GameFixedData},
    map::{m_Map},
};
use darkshuffle::systems::{
    game::contracts::{game_systems, IGameSystemsDispatcher, IGameSystemsDispatcherTrait},
    map::contracts::{map_systems, IMapSystemsDispatcher, IMapSystemsDispatcherTrait},
    draft::contracts::{draft_systems, IDraftSystemsDispatcher, IDraftSystemsDispatcherTrait},
    config::contracts::{config_systems, IConfigSystemsDispatcher, IConfigSystemsDispatcherTrait},
    battle::contracts::{battle_systems, IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait}
};

use starknet::{ContractAddress, contract_address_const};

fn namespace_def() -> NamespaceDef {
    let ndef = NamespaceDef {
        namespace: DEFAULT_NS_STR(), resources: [
            TestResource::Model(m_Battle::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Board::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_WorldConfig::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_GameSettings::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Draft::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Game::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_GameFixedData::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_GameEffects::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Map::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Event(darkshuffle::models::game::e_GameActionEvent::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Event(achievement::events::index::e_TrophyCreation::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Event(achievement::events::index::e_TrophyProgression::TEST_CLASS_HASH.try_into().unwrap()),

            TestResource::Contract(game_systems::TEST_CLASS_HASH),
            TestResource::Contract(map_systems::TEST_CLASS_HASH),
            TestResource::Contract(draft_systems::TEST_CLASS_HASH),
            TestResource::Contract(config_systems::TEST_CLASS_HASH),
            TestResource::Contract(battle_systems::TEST_CLASS_HASH),
        ].span()
    };

    ndef
}

fn contract_defs() -> Span<ContractDef> {
    [
        ContractDefTrait::new(DEFAULT_NS(), @"game_systems")
            .with_writer_of([dojo::utils::bytearray_hash(DEFAULT_NS())].span()),
        ContractDefTrait::new(DEFAULT_NS(), @"map_systems")
            .with_writer_of([dojo::utils::bytearray_hash(DEFAULT_NS())].span()),
        ContractDefTrait::new(DEFAULT_NS(), @"draft_systems")
            .with_writer_of([dojo::utils::bytearray_hash(DEFAULT_NS())].span()),
        ContractDefTrait::new(DEFAULT_NS(), @"config_systems")
            .with_writer_of([dojo::utils::bytearray_hash(DEFAULT_NS())].span()),
        ContractDefTrait::new(DEFAULT_NS(), @"battle_systems")
            .with_writer_of([dojo::utils::bytearray_hash(DEFAULT_NS())].span()),
    ].span()
}


// used to spawn a test world with all the models and systems registered
fn spawn_darkshuffle() -> dojo::world::WorldStorage {
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    world.dispatcher.grant_owner(dojo::utils::bytearray_hash(DEFAULT_NS()), contract_address_const::<'player1'>());

    world.dispatcher.uuid();

    starknet::testing::set_contract_address(contract_address_const::<'player1'>());
    starknet::testing::set_account_contract_address(contract_address_const::<'player1'>());
    starknet::testing::set_block_timestamp(300000);
    
    world
}
