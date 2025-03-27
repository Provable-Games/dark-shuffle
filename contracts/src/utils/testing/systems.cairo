use darkshuffle::systems::game::contracts::{IGameSystemsDispatcher, IGameSystemsDispatcherTrait, game_systems};
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

fn deploy_game_token_mock(ref world: WorldStorage) -> ContractAddress {
    let call_data: Array<felt252> = array![];
    deploy_contract(GameTokenMock::TEST_CLASS_HASH, call_data.span())
}
