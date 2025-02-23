use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct WorldConfig {
    #[key]
    config_id: u8,
    game_token_address: ContractAddress,
    game_count: u64,
    card_count: u64,
    settings_count: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GameSettings {
    #[key]
    settings_id: u32,
    start_health: u8,
    start_energy: u8,
    start_hand_size: u8,
    draft_size: u8,
    max_energy: u8,
    max_hand_size: u8,
    include_spells: bool,
    card_ids_allowed: Span<u64>,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct SettingsCounter {
    #[key]
    id: felt252,
    count: u32,
}

#[generate_trait]
impl GameSettingsImpl of GameSettingsTrait {
    fn exists(self: GameSettings) -> bool {
        self.start_health.is_non_zero()
    }
}
