#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game_id: u64,
    pub hero_health: u8,
    pub hero_xp: u16,
    pub monsters_slain: u16,
    pub map_level: u8,
    pub map_depth: u8,
    pub last_node_id: u8,
    pub action_count: u16,
    pub state: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct GameEffects {
    #[key]
    pub game_id: u64,
    pub first_attack: u8,
    pub first_health: u8,
    pub all_attack: u8,
    pub hunter_attack: u8,
    pub hunter_health: u8,
    pub magical_attack: u8,
    pub magical_health: u8,
    pub brute_attack: u8,
    pub brute_health: u8,
    pub hero_dmg_reduction: u8,
    pub hero_card_heal: bool,
    pub card_draw: u8,
    pub play_creature_heal: u8,
    pub start_bonus_energy: u8,
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum GameState {
    Draft,
    Battle,
    Map,
    Over,
}

pub impl GameStateIntoU8 of Into<GameState, u8> {
    fn into(self: GameState) -> u8 {
        match self {
            GameState::Draft => 0,
            GameState::Battle => 1,
            GameState::Map => 2,
            GameState::Over => 3,
        }
    }
}

pub impl IntoU8GameState of Into<u8, GameState> {
    fn into(self: u8) -> GameState {
        let state: felt252 = self.into();
        match state {
            0 => GameState::Draft,
            1 => GameState::Battle,
            2 => GameState::Map,
            3 => GameState::Over,
            _ => GameState::Over,
        }
    }
}

#[generate_trait]
pub impl GameOwnerImpl of GameOwnerTrait {
    fn assert_draft(self: Game) {
        assert(self.state.into() == GameState::Draft, 'Not Draft');
    }

    fn assert_generate_tree(self: Game) {
        assert(self.state.into() == GameState::Map, 'Not Map');
        assert(self.map_depth == 0, 'Tree Not Completed');
    }

    fn assert_select_node(self: Game) {
        assert(self.state.into() == GameState::Map, 'Not Map');
    }

    fn exists(self: Game) -> bool {
        self.hero_xp != 0
    }
}

#[derive(Copy, Drop, Serde)]
#[dojo::event(historical: true)]
pub struct GameActionEvent {
    #[key]
    pub tx_hash: felt252,
    pub game_id: u64,
    pub count: u16,
}
