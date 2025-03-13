use starknet::ContractAddress;

#[derive(Introspect, Copy, Drop, Serde)]
#[dojo::model]
pub struct GameSettings {
    #[key]
    settings_id: u32,
    start_health: u8,
    persistent_health: bool,
    map: MapSettings,
    battle: BattleSettings,
    draft: DraftSettings,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct MapSettings {
    max_branches: u8,
    enemy_attack: u8,
    enemy_health: u8,
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
        self.start_health.is_non_zero()
    }
}
