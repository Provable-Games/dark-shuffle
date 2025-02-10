use darkshuffle::constants::{WORLD_CONFIG_ID};
use darkshuffle::interface::{IGameTokenDispatcher, IGameTokenDispatcherTrait};
use darkshuffle::models::config::{SettingDetails, WorldConfig};
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[generate_trait]
impl ConfigUtilsImpl of ConfigUtilsTrait {
    // TODO: Switch this to get settings from game_manager (currently game_systems), eventually settings_manager
    fn get_game_settings(world: WorldStorage, game_id: u64) -> SettingDetails {
        let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
        let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };
        let game_settings: SettingDetails = world.read_model(game_token.settings_id(game_id.into()));
        game_settings
    }
}
