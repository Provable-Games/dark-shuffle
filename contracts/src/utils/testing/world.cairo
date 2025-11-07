use core::array::{ArrayTrait, SpanTrait};
use darkshuffle::constants::DEFAULT_NS;
use darkshuffle::models::battle::{m_Battle, m_BattleResources};
use darkshuffle::models::card::{m_Card, m_CreatureCard, m_SpellCard};
use darkshuffle::models::config::{m_CardsCounter, m_GameSettings, m_GameSettingsMetadata};
use darkshuffle::models::draft::m_Draft;
use darkshuffle::models::game::{m_Game, m_GameEffects};
use darkshuffle::models::map::m_Map;
use darkshuffle::systems::battle::contracts::{IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait, battle_systems};
use darkshuffle::systems::config::contracts::{IConfigSystemsDispatcher, IConfigSystemsDispatcherTrait, config_systems};
use darkshuffle::systems::game::contracts::{IGameSystemsDispatcher, IGameSystemsDispatcherTrait, game_systems};
use darkshuffle::utils::testing::systems::deploy_game_systems;
use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{
    ContractDef, ContractDefTrait, NamespaceDef, TestResource, WorldStorageTestTrait, spawn_test_world,
};
use starknet::{ContractAddress, contract_address_const};

fn namespace_def() -> NamespaceDef {
    let ndef = NamespaceDef {
        namespace: DEFAULT_NS(),
        resources: [
            TestResource::Model(m_Battle::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_BattleResources::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_GameSettings::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_GameSettingsMetadata::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Draft::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Game::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_GameEffects::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Map::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Card::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_CreatureCard::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_SpellCard::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_CardsCounter::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(
                tournaments::components::models::game::m_GameMetadata::TEST_CLASS_HASH.try_into().unwrap(),
            ),
            TestResource::Model(
                tournaments::components::models::game::m_TokenMetadata::TEST_CLASS_HASH.try_into().unwrap(),
            ),
            TestResource::Model(
                tournaments::components::models::game::m_GameCounter::TEST_CLASS_HASH.try_into().unwrap(),
            ),
            TestResource::Model(tournaments::components::models::game::m_Score::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(tournaments::components::models::game::m_Settings::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(
                tournaments::components::models::game::m_SettingsDetails::TEST_CLASS_HASH.try_into().unwrap(),
            ),
            TestResource::Model(
                tournaments::components::models::game::m_SettingsCounter::TEST_CLASS_HASH.try_into().unwrap(),
            ),
            TestResource::Event(darkshuffle::models::game::e_GameActionEvent::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Contract(game_systems::TEST_CLASS_HASH),
            TestResource::Contract(config_systems::TEST_CLASS_HASH),
            TestResource::Contract(battle_systems::TEST_CLASS_HASH),
        ]
            .span(),
    };

    ndef
}

fn contract_defs() -> Span<ContractDef> {
    [
        ContractDefTrait::new(@DEFAULT_NS(), @"game_systems")
            .with_writer_of([dojo::utils::bytearray_hash(@DEFAULT_NS())].span())
            .with_init_calldata(array![contract_address_const::<'player1'>().into()].span()),
        ContractDefTrait::new(@DEFAULT_NS(), @"config_systems")
            .with_writer_of([dojo::utils::bytearray_hash(@DEFAULT_NS())].span()),
        ContractDefTrait::new(@DEFAULT_NS(), @"battle_systems")
            .with_writer_of([dojo::utils::bytearray_hash(@DEFAULT_NS())].span()),
    ]
        .span()
}


// used to spawn a test world with all the models and systems registered
fn spawn_darkshuffle() -> (dojo::world::WorldStorage, IGameSystemsDispatcher) {
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    world.dispatcher.grant_owner(dojo::utils::bytearray_hash(@DEFAULT_NS()), contract_address_const::<'player1'>());

    world.dispatcher.uuid();

    starknet::testing::set_contract_address(contract_address_const::<'player1'>());
    starknet::testing::set_account_contract_address(contract_address_const::<'player1'>());
    starknet::testing::set_block_timestamp(300000);

    let game_systems_dispatcher = deploy_game_systems(ref world);

    (world, game_systems_dispatcher)
}
