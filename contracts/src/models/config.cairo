use starknet::ContractAddress;

#[derive(Introspect, Drop, Serde)]
#[dojo::model]
pub struct GameSettingsMetadata {
    #[key]
    settings_id: u32,
    name: felt252,
    description: ByteArray,
    created_by: ContractAddress,
    created_at: u64,
}

#[derive(Introspect, Copy, Drop, Serde)]
#[dojo::model]
pub struct GameSettings {
    #[key]
    settings_id: u32,
    starting_health: u8,
    persistent_health: bool,
    map: MapSettings,
    battle: BattleSettings,
    draft: DraftSettings,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct MapSettings {
    possible_branches: u8,
    enemy_starting_attack: u8,
    enemy_starting_health: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct BattleSettings {
    start_energy: u8,
    start_hand_size: u8,
    max_energy: u8,
    max_hand_size: u8,
    draw_amount: u8,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub struct DraftSettings {
    draft_size: u8,
    card_ids: Span<u64>,
    card_rarity_weights: CardRarityWeights,
    auto_draft: bool,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct CardRarityWeights {
    common: u8,
    uncommon: u8,
    rare: u8,
    epic: u8,
    legendary: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct SettingsCounter {
    #[key]
    id: felt252,
    count: u32,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct CardsCounter {
    #[key]
    id: felt252,
    count: u64,
}

#[generate_trait]
impl GameSettingsImpl of GameSettingsTrait {
    fn exists(self: GameSettings) -> bool {
        self.starting_health.is_non_zero()
    }
}
