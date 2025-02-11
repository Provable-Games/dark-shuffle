use darkshuffle::systems::{
    battle::contracts::{IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait, battle_systems},
    config::contracts::{IConfigSystemsDispatcher, IConfigSystemsDispatcherTrait, config_systems},
    draft::contracts::{IDraftSystemsDispatcher, IDraftSystemsDispatcherTrait, draft_systems},
    game::contracts::{IGameSystemsDispatcher, IGameSystemsDispatcherTrait, game_systems},
    map::contracts::{IMapSystemsDispatcher, IMapSystemsDispatcherTrait, map_systems},
};
use darkshuffle::utils::testing::mock::gameTokenMock::{GameTokenMock};

use tournaments::components::game::{IGameDispatcher, IGameDispatcherTrait, IGameDetails, ISettings, game_component};
use dojo::model::ModelStorage;

use dojo::world::WorldStorage;
use dojo::world::WorldStorageTrait;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo_cairo_test::deploy_contract;

use starknet::{ContractAddress};

fn deploy_system(ref world: WorldStorage, name: ByteArray) -> ContractAddress {
    let (contract_address, _) = world.dns(@name).unwrap();
    contract_address
}

fn deploy_game_systems(ref world: WorldStorage) -> (IGameSystemsDispatcher, IGameDispatcher) {
    let game_systems_address = deploy_system(ref world, "game_systems");
    let game_systems_dispatcher = IGameSystemsDispatcher { contract_address: game_systems_address };
    let game_component_dispatcher = IGameDispatcher { contract_address: game_systems_address };

    (game_systems_dispatcher, game_component_dispatcher)
}

fn deploy_map_systems(ref world: WorldStorage) -> IMapSystemsDispatcher {
    let map_systems_address = deploy_system(ref world, "map_systems");
    let map_systems_dispatcher = IMapSystemsDispatcher { contract_address: map_systems_address };

    map_systems_dispatcher
}

fn deploy_draft_systems(ref world: WorldStorage) -> IDraftSystemsDispatcher {
    let draft_systems_address = deploy_system(ref world, "draft_systems");
    let draft_systems_dispatcher = IDraftSystemsDispatcher { contract_address: draft_systems_address };

    draft_systems_dispatcher
}

fn deploy_battle_systems(ref world: WorldStorage) -> IBattleSystemsDispatcher {
    let battle_systems_address = deploy_system(ref world, "battle_systems");
    let battle_systems_dispatcher = IBattleSystemsDispatcher { contract_address: battle_systems_address };

    battle_systems_dispatcher
}

fn deploy_config_systems(ref world: WorldStorage) -> IConfigSystemsDispatcher {
    let config_systems_address = deploy_system(ref world, "config_systems");
    let config_systems_dispatcher = IConfigSystemsDispatcher { contract_address: config_systems_address };

    config_systems_dispatcher
}

fn deploy_game_token_mock(ref world: WorldStorage) -> ContractAddress {
    let call_data: Array<felt252> = array![];
    let game_token_address = deploy_contract(GameTokenMock::TEST_CLASS_HASH, call_data.span());

    game_token_address
}
