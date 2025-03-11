use darkshuffle::systems::battle::contracts::{IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait, battle_systems};
use darkshuffle::systems::config::contracts::{IConfigSystemsDispatcher, IConfigSystemsDispatcherTrait, config_systems};
use darkshuffle::systems::draft::contracts::{IDraftSystemsDispatcher, IDraftSystemsDispatcherTrait, draft_systems};
use darkshuffle::systems::game::contracts::{IGameSystemsDispatcher, IGameSystemsDispatcherTrait, game_systems};
use darkshuffle::systems::map::contracts::{IMapSystemsDispatcher, IMapSystemsDispatcherTrait, map_systems};
use darkshuffle::utils::testing::mock::gameTokenMock::GameTokenMock;
use dojo::model::ModelStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use dojo_cairo_test::deploy_contract;
use starknet::ContractAddress;

fn deploy_system(ref world: WorldStorage, name: ByteArray) -> ContractAddress {
    let (contract_address, _) = world.dns(@name).unwrap();
    contract_address
}

fn deploy_game_systems(ref world: WorldStorage) -> IGameSystemsDispatcher {
    let game_systems_address = deploy_system(ref world, "game_systems");
    IGameSystemsDispatcher { contract_address: game_systems_address }
}

fn deploy_map_systems(ref world: WorldStorage) -> IMapSystemsDispatcher {
    let map_systems_address = deploy_system(ref world, "map_systems");
    IMapSystemsDispatcher { contract_address: map_systems_address }
}

fn deploy_draft_systems(ref world: WorldStorage) -> IDraftSystemsDispatcher {
    let draft_systems_address = deploy_system(ref world, "draft_systems");
    IDraftSystemsDispatcher { contract_address: draft_systems_address }
}

fn deploy_battle_systems(ref world: WorldStorage) -> IBattleSystemsDispatcher {
    let battle_systems_address = deploy_system(ref world, "battle_systems");
    IBattleSystemsDispatcher { contract_address: battle_systems_address }
}

fn deploy_config_systems(ref world: WorldStorage) -> IConfigSystemsDispatcher {
    let config_systems_address = deploy_system(ref world, "config_systems");
    IConfigSystemsDispatcher { contract_address: config_systems_address }
}

fn deploy_game_token_mock(ref world: WorldStorage) -> ContractAddress {
    let call_data: Array<felt252> = array![];
    deploy_contract(GameTokenMock::TEST_CLASS_HASH, call_data.span())
}
