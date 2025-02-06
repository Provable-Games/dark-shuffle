use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use darkshuffle::models::config::{WorldConfig, GameSettings};
use darkshuffle::interface::{IGameTokenDispatcher, IGameTokenDispatcherTrait};
use darkshuffle::constants::{WORLD_CONFIG_ID};

#[generate_trait]
impl ConfigUtilsImpl of ConfigUtilsTrait {
    fn get_game_settings(world: WorldStorage, game_id: u64) -> GameSettings {
        let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
        let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };
        let game_settings: GameSettings = world.read_model(game_token.settings_id(game_id.into()));
        game_settings
    }
}
