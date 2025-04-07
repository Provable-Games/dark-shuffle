#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct Card {
    #[key]
    id: u64,
    name: felt252,
    rarity: u8,
    cost: u8,
    category: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct CreatureCard {
    #[key]
    id: u64,
    attack: u8,
    health: u8,
    card_type: u8,
    play_effect: CardEffect,
    death_effect: CardEffect,
    attack_effect: CardEffect,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct SpellCard {
    #[key]
    id: u64,
    card_type: u8,
    effect: CardEffect,
    extra_effect: CardEffect,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct CardEffect {
    modifier: CardModifier,
    bonus: EffectBonus,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct CardModifier {
    _type: u8,
    value_type: u8,
    value: u8,
    requirement: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct EffectBonus {
    value: u8,
    requirement: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub enum CardCategory {
    None,
    Creature,
    Spell,
}

#[derive(IntrospectPacked, PartialEq, Copy, Drop, Serde)]
pub enum Modifier {
    None,
    HeroHealth,
    HeroEnergy,
    HeroDamageReduction,
    EnemyMarks,
    EnemyAttack,
    EnemyHealth,
    NextAllyAttack,
    NextAllyHealth,
    AllAttack,
    AllHealth,
    AllyAttack,
    AllyHealth,
    AllyStats,
    SelfAttack,
    SelfHealth,
}

#[derive(IntrospectPacked, PartialEq, Copy, Drop, Serde)]
pub enum ValueType {
    None,
    Fixed,
    PerAlly,
}

#[derive(IntrospectPacked, PartialEq, Copy, Drop, Serde)]
pub enum Requirement {
    None,
    EnemyWeak,
    HasAlly,
    NoAlly,
}

#[derive(IntrospectPacked, PartialEq, Copy, Drop, Serde)]
pub enum CardRarity {
    None,
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

#[derive(IntrospectPacked, PartialEq, Copy, Drop, Serde)]
pub enum CardType {
    None,
    Hunter,
    Brute,
    Magical,
}

impl U8IntoCardCategory of Into<u8, CardCategory> {
    fn into(self: u8) -> CardCategory {
        let card_category: felt252 = self.into();
        match card_category {
            0 => CardCategory::None,
            1 => CardCategory::Creature,
            2 => CardCategory::Spell,
            _ => CardCategory::None,
        }
    }
}

impl CardCategoryIntoU8 of Into<CardCategory, u8> {
    fn into(self: CardCategory) -> u8 {
        match self {
            CardCategory::None => 0,
            CardCategory::Creature => 1,
            CardCategory::Spell => 2,
        }
    }
}

impl U8IntoCardRarity of Into<u8, CardRarity> {
    fn into(self: u8) -> CardRarity {
        let rarity: felt252 = self.into();
        match rarity {
            0 => CardRarity::None,
            1 => CardRarity::Common,
            2 => CardRarity::Uncommon,
            3 => CardRarity::Rare,
            4 => CardRarity::Epic,
            5 => CardRarity::Legendary,
            _ => CardRarity::None,
        }
    }
}

impl CardRarityIntoU8 of Into<CardRarity, u8> {
    fn into(self: CardRarity) -> u8 {
        match self {
            CardRarity::None => 0,
            CardRarity::Common => 1,
            CardRarity::Uncommon => 2,
            CardRarity::Rare => 3,
            CardRarity::Epic => 4,
            CardRarity::Legendary => 5,
        }
    }
}

impl CardTypeIntoU8 of Into<CardType, u8> {
    fn into(self: CardType) -> u8 {
        match self {
            CardType::None => 0,
            CardType::Hunter => 1,
            CardType::Brute => 2,
            CardType::Magical => 3,
        }
    }
}

impl U8IntoCardType of Into<u8, CardType> {
    fn into(self: u8) -> CardType {
        let card_type: felt252 = self.into();
        match card_type {
            0 => CardType::None,
            1 => CardType::Hunter,
            2 => CardType::Brute,
            3 => CardType::Magical,
            _ => CardType::None,
        }
    }
}

impl ModifierIntoU8 of Into<Modifier, u8> {
    fn into(self: Modifier) -> u8 {
        match self {
            Modifier::None => 0,
            Modifier::HeroHealth => 1,
            Modifier::HeroEnergy => 2,
            Modifier::HeroDamageReduction => 3,
            Modifier::EnemyMarks => 4,
            Modifier::EnemyAttack => 5,
            Modifier::EnemyHealth => 6,
            Modifier::NextAllyAttack => 7,
            Modifier::NextAllyHealth => 8,
            Modifier::AllAttack => 9,
            Modifier::AllHealth => 10,
            Modifier::AllyAttack => 11,
            Modifier::AllyHealth => 12,
            Modifier::AllyStats => 13,
            Modifier::SelfAttack => 14,
            Modifier::SelfHealth => 15,
        }
    }
}

impl U8IntoModifier of Into<u8, Modifier> {
    fn into(self: u8) -> Modifier {
        let modifier: felt252 = self.into();
        match modifier {
            0 => Modifier::None,
            1 => Modifier::HeroHealth,
            2 => Modifier::HeroEnergy,
            3 => Modifier::HeroDamageReduction,
            4 => Modifier::EnemyMarks,
            5 => Modifier::EnemyAttack,
            6 => Modifier::EnemyHealth,
            7 => Modifier::NextAllyAttack,
            8 => Modifier::NextAllyHealth,
            9 => Modifier::AllAttack,
            10 => Modifier::AllHealth,
            11 => Modifier::AllyAttack,
            12 => Modifier::AllyHealth,
            13 => Modifier::AllyStats,
            14 => Modifier::SelfAttack,
            15 => Modifier::SelfHealth,
            _ => Modifier::HeroHealth,
        }
    }
}

impl ValueTypeIntoU8 of Into<ValueType, u8> {
    fn into(self: ValueType) -> u8 {
        match self {
            ValueType::None => 0,
            ValueType::Fixed => 1,
            ValueType::PerAlly => 2,
        }
    }
}

impl U8IntoValueType of Into<u8, ValueType> {
    fn into(self: u8) -> ValueType {
        let value_type: felt252 = self.into();
        match value_type {
            0 => ValueType::None,
            1 => ValueType::Fixed,
            2 => ValueType::PerAlly,
            _ => ValueType::Fixed,
        }
    }
}

impl RequirementIntoU8 of Into<Requirement, u8> {
    fn into(self: Requirement) -> u8 {
        match self {
            Requirement::None => 0,
            Requirement::EnemyWeak => 1,
            Requirement::HasAlly => 2,
            Requirement::NoAlly => 3,
        }
    }
}

impl U8IntoRequirement of Into<u8, Requirement> {
    fn into(self: u8) -> Requirement {
        let requirement: felt252 = self.into();
        match requirement {
            0 => Requirement::None,
            1 => Requirement::EnemyWeak,
            2 => Requirement::HasAlly,
            3 => Requirement::NoAlly,
            _ => Requirement::EnemyWeak,
        }
    }
}
