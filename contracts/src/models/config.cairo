use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct WorldConfig {
    #[key]
    config_id: u8,
    game_token_address: ContractAddress,
    game_count: u256,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct SettingsCount {
    #[key]
    id: felt252,
    count: u32,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct SettingDetails {
    #[key]
    settings_id: u32,
    start_health: u8,
    start_energy: u8,
    start_hand_size: u8,
    draft_size: u8,
    max_energy: u8,
    max_hand_size: u8,
    include_spells: bool,
}

#[generate_trait]
impl SettingDetailsImpl of SettingDetailsTrait {
    fn exists(self: SettingDetails) -> bool {
        self.start_health.is_non_zero()
    }
}
