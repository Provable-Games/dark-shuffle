use darkshuffle::constants::{LAST_NODE_DEPTH, WORLD_CONFIG_ID};
use darkshuffle::models::config::{WorldConfig};
use dojo::event::EventStorage;
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use openzeppelin::token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
use starknet::{ContractAddress, get_caller_address};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    game_id: u64,
    season_id: u32,
    hero_health: u8,
    hero_xp: u16,
    monsters_slain: u16,
    map_level: u8,
    map_depth: u8,
    last_node_id: u8,
    action_count: u16,
    state: GameState,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct GameFixedData {
    #[key]
    game_id: u64,
    player_name: felt252,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct GameEffects {
    #[key]
    game_id: u64,
    first_attack: u8,
    first_health: u8,
    first_creature_cost: u8,
    all_attack: u8,
    hunter_attack: u8,
    hunter_health: u8,
    magical_attack: u8,
    magical_health: u8,
    brute_attack: u8,
    brute_health: u8,
    hero_dmg_reduction: u8,
    hero_card_heal: bool,
    card_draw: u8,
    play_creature_heal: u8,
    start_bonus_energy: u8
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum GameState {
    Draft,
    Battle,
    Map,
    Over,
}

impl GameStateIntoU8 of Into<GameState, u8> {
    fn into(self: GameState) -> u8 {
        match self {
            GameState::Draft => 0,
            GameState::Battle => 1,
            GameState::Map => 2,
            GameState::Over => 3,
        }
    }
}

#[generate_trait]
impl GameOwnerImpl of GameOwnerTrait {
    fn assert_owner(self: Game, world: WorldStorage) {
        let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
        let game_token = IERC721Dispatcher { contract_address: world_config.game_token_address };
        assert(game_token.owner_of(self.game_id.into()) == get_caller_address(), 'Not Owner');
    }

    fn assert_draft(self: Game) {
        assert(self.state == GameState::Draft, 'Not Draft');
    }

    fn assert_generate_tree(self: Game) {
        assert(self.state == GameState::Map, 'Not Map');
        assert(self.map_depth == LAST_NODE_DEPTH, 'Tree Not Completed');
    }

    fn assert_select_node(self: Game) {
        assert(self.state == GameState::Map, 'Not Map');
    }

    fn exists(self: Game) -> bool {
        self.hero_xp.is_non_zero()
    }
}

#[derive(Copy, Drop, Serde)]
#[dojo::event(historical: true)]
pub struct GameActionEvent {
    #[key]
    tx_hash: felt252,
    game_id: u64,
    count: u16
}
