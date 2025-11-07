#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct Map {
    #[key]
    pub game_id: u64,
    #[key]
    pub level: u8,
    pub seed: u128,
}

#[derive(Copy, Drop, Serde)]
pub struct MonsterNode {
    pub monster_id: u8,
    pub attack: u8,
    pub health: u16,
}
