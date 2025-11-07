use starknet::ContractAddress;

#[derive(Introspect, Drop, Serde)]
#[dojo::model]
pub struct GameSettingsMetadata {
    #[key]
    pub settings_id: u32,
    pub name: felt252,
    pub description: ByteArray,
    pub created_by: ContractAddress,
    pub created_at: u64,
}

#[derive(Introspect, Copy, Drop, Serde)]
#[dojo::model]
pub struct GameSettings {
    #[key]
    pub settings_id: u32,
    pub starting_health: u8,
    pub persistent_health: bool,
    pub map: MapSettings,
    pub battle: BattleSettings,
    pub draft: DraftSettings,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct MapSettings {
    pub level_depth: u8,
    pub possible_branches: u8,
    pub enemy_attack_min: u8,
    pub enemy_attack_max: u8,
    pub enemy_health_min: u8,
    pub enemy_health_max: u8,
    pub enemy_attack_scaling: u8,
    pub enemy_health_scaling: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct BattleSettings {
    pub start_energy: u8,
    pub start_hand_size: u8,
    pub max_energy: u8,
    pub max_hand_size: u8,
    pub draw_amount: u8,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub struct DraftSettings {
    pub draft_size: u8,
    pub card_ids: Span<u64>,
    pub card_rarity_weights: CardRarityWeights,
    pub auto_draft: bool,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct CardRarityWeights {
    pub common: u8,
    pub uncommon: u8,
    pub rare: u8,
    pub epic: u8,
    pub legendary: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct SettingsCounter {
    #[key]
    pub id: felt252,
    pub count: u32,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct CardsCounter {
    #[key]
    pub id: felt252,
    pub count: u64,
}

#[generate_trait]
pub impl GameSettingsImpl of GameSettingsTrait {
    fn exists(self: GameSettings) -> bool {
        self.starting_health != 0
    }
}
