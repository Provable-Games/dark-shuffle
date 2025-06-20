// SPDX-License-Identifier: UNLICENSED

use core::option::Option;
use starknet::{ContractAddress, testing, contract_address_const};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{
    spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    WorldStorageTestTrait,
};

use denshokan::constants::DEFAULT_NS;
use game_components_denshokan::interface::{IDenshokanDispatcher};
use game_components_minigame::interface::{IMinigameDetailsDispatcher};

use denshokan::models::denshokan::{
    m_GameMetadata, m_GameRegistry, m_GameRegistryId, m_GameCounter, m_MinterRegistry,
    m_MinterRegistryId, m_MinterCounter, m_TokenMetadata, m_TokenCounter, m_TokenPlayerName,
    m_TokenObjective,
};
use game_components_minigame::tests::models::minigame::{
    m_Score, m_ScoreObjective, m_ScoreObjectiveCount, m_Settings, m_SettingsDetails,
    m_SettingsCounter,
};
use game_components_metagame::tests::models::metagame::{m_Context};

use game_components_metagame::tests::mocks::metagame_mock::{
    metagame_mock, IMetagameMockDispatcher, IMetagameMockInitDispatcher,
    IMetagameMockInitDispatcherTrait,
};
use game_components_minigame::tests::mocks::minigame_mock::{
    minigame_mock, IMinigameMockDispatcher, IMinigameMockDispatcherTrait,
    IMinigameMockInitDispatcher, IMinigameMockInitDispatcherTrait,
};

// use denshokan::tests::utils;

// Test constants
const OWNER: felt252 = 'OWNER';
const PLAYER: felt252 = 'PLAYER';
const GAME_CREATOR: felt252 = 'GAME_CREATOR';
const GAME_NAME: felt252 = 'TestGame';
const DEVELOPER: felt252 = 'TestDev';
const PUBLISHER: felt252 = 'TestPub';
const GENRE: felt252 = 'Action';
const PLAYER_NAME: felt252 = 'TestPlayer';

fn OWNER_ADDR() -> ContractAddress {
    contract_address_const::<OWNER>()
}

fn PLAYER_ADDR() -> ContractAddress {
    contract_address_const::<PLAYER>()
}

fn GAME_CREATOR_ADDR() -> ContractAddress {
    contract_address_const::<GAME_CREATOR>()
}

#[derive(Drop)]
pub struct TestContracts {
    pub world: WorldStorage,
    pub denshokan: IDenshokanDispatcher,
    pub minigame_mock: IMinigameMockDispatcher,
    pub minigame_mock_score: IMinigameDetailsDispatcher,
    pub metagame_mock: IMetagameMockDispatcher,
}

//
// Setup
//

fn setup_uninitialized() -> WorldStorage {
    testing::set_block_number(1);
    testing::set_block_timestamp(1000);

    let ndef = NamespaceDef {
        namespace: DEFAULT_NS(),
        resources: [
            // Denshokan models
            TestResource::Model(m_GameMetadata::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_GameRegistry::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_GameRegistryId::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_GameCounter::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_MinterRegistry::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_MinterRegistryId::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_MinterCounter::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_TokenMetadata::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_TokenCounter::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_TokenPlayerName::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_TokenObjective::TEST_CLASS_HASH.try_into().unwrap()),
            // Minigame models
            TestResource::Model(m_ScoreObjective::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ScoreObjectiveCount::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Settings::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_SettingsDetails::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_SettingsCounter::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_Score::TEST_CLASS_HASH.try_into().unwrap()),
            // Metagame models
            TestResource::Model(m_Context::TEST_CLASS_HASH.try_into().unwrap()),
            // Events
            TestResource::Event(
                denshokan::denshokan::denshokan::e_Owners::TEST_CLASS_HASH.try_into().unwrap(),
            ),
            TestResource::Event(
                denshokan::denshokan::denshokan::e_ScoreUpdate::TEST_CLASS_HASH.try_into().unwrap(),
            ),
            TestResource::Event(
                denshokan::denshokan::denshokan::e_ObjectiveData::TEST_CLASS_HASH
                    .try_into()
                    .unwrap(),
            ),
            TestResource::Event(
                denshokan::denshokan::denshokan::e_SettingsData::TEST_CLASS_HASH
                    .try_into()
                    .unwrap(),
            ),
            TestResource::Event(
                denshokan::denshokan::denshokan::e_TokenContextData::TEST_CLASS_HASH
                    .try_into()
                    .unwrap(),
            ),
            // Contracts
            TestResource::Contract(denshokan::denshokan::denshokan::TEST_CLASS_HASH),
            TestResource::Contract(minigame_mock::TEST_CLASS_HASH),
            TestResource::Contract(metagame_mock::TEST_CLASS_HASH),
        ]
            .span(),
    };

    let mut contract_defs: Array<ContractDef> = array![
        ContractDefTrait::new(@DEFAULT_NS(), @"denshokan")
            .with_writer_of([dojo::utils::bytearray_hash(@DEFAULT_NS())].span()),
        ContractDefTrait::new(@DEFAULT_NS(), @"minigame_mock")
            .with_writer_of([dojo::utils::bytearray_hash(@DEFAULT_NS())].span()),
        ContractDefTrait::new(@DEFAULT_NS(), @"metagame_mock")
            .with_writer_of([dojo::utils::bytearray_hash(@DEFAULT_NS())].span()),
    ];

    let mut world: WorldStorage = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs.span());

    world
}

pub fn setup() -> TestContracts {
    let mut world = setup_uninitialized();

    let denshokan_address = match world.dns(@"denshokan") {
        Option::Some((address, _)) => address,
        Option::None => panic!("Denshokan contract not found in world DNS"),
    };

    let minigame_mock_address = match world.dns(@"minigame_mock") {
        Option::Some((address, _)) => address,
        Option::None => panic!("Game mock contract not found in world DNS"),
    };

    let metagame_mock_address = match world.dns(@"metagame_mock") {
        Option::Some((address, _)) => address,
        Option::None => panic!("App mock contract not found in world DNS"),
    };

    let denshokan = IDenshokanDispatcher { contract_address: denshokan_address };
    let minigame_mock = IMinigameMockDispatcher { contract_address: minigame_mock_address };
    let minigame_mock_init = IMinigameMockInitDispatcher {
        contract_address: minigame_mock_address,
    };
    let minigame_mock_score = IMinigameDetailsDispatcher {
        contract_address: minigame_mock_address,
    };
    let metagame_mock = IMetagameMockDispatcher { contract_address: metagame_mock_address };
    let metagame_mock_init = IMetagameMockInitDispatcher {
        contract_address: metagame_mock_address,
    };

    let (
        _creator, // We'll ignore this and use game_mock_address instead
        name,
        description,
        developer,
        publisher,
        genre,
        image,
        color,
    ) =
        create_test_game_metadata();

    // Initialize game mock to support IGameToken interface
    // Use the game_mock_address as the creator since it implements IGameToken
    minigame_mock_init
        .initializer(
            minigame_mock_address, // Use the deployed contract address as creator
            name,
            description,
            developer,
            publisher,
            genre,
            image,
            Option::Some(color),
            Option::None,
            DEFAULT_NS(),
            denshokan_address,
        );

    // create game objective
    minigame_mock.create_objective_score(100);

    // create game settings
    minigame_mock.create_settings_difficulty("Test Settings", "Test Settings Description", 1);

    metagame_mock_init.initializer(DEFAULT_NS(), denshokan_address);

    TestContracts { world, denshokan, minigame_mock, minigame_mock_score, metagame_mock }
}

//
// Helper functions
//

fn create_test_game_metadata() -> (
    ContractAddress, felt252, ByteArray, felt252, felt252, felt252, ByteArray, ByteArray,
) {
    (
        GAME_CREATOR_ADDR(),
        GAME_NAME,
        "A test game description",
        DEVELOPER,
        PUBLISHER,
        GENRE,
        "https://example.com/image.png",
        "test_color",
    )
}
