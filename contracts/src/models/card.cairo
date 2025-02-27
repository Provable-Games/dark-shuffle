#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Card {
    #[key]
    id: u64,
    name: felt252,
    rarity: CardRarity,
    cost: u8,
    card_type: CardType,
    card_details: CardDetails,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub enum CardDetails {
    creature_card: CreatureCard,
    spell_card: SpellCard,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub struct CreatureCard {
    attack: u8,
    health: u8,
    play_effect: Option<CardEffect>,
    death_effect: Option<CardEffect>,
    attack_effect: Option<CardEffect>,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub struct SpellCard {
    effect: CardEffect,
    extra_effect: Option<CardEffect>,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub struct CardEffect {
    modifier: CardModifier,
    bonus: Option<EffectBonus>,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub struct CardModifier {
    _type: Modifier,
    value_type: ValueType,
    value: u8,
    requirement: Option<Requirement>,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub struct EffectBonus {
    value: u8,
    requirement: Requirement,
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum Modifier {
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

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum ValueType {
    Fixed,
    PerAlly,
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum Requirement {
    EnemyWeak,
    HasAlly,
    NoAlly,
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum CardRarity {
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

impl CardRarityIntoU8 of Into<CardRarity, u8> {
    fn into(self: CardRarity) -> u8 {
        match self {
            CardRarity::Common => 0,
            CardRarity::Uncommon => 1,
            CardRarity::Rare => 2,
            CardRarity::Epic => 3,
            CardRarity::Legendary => 4,
        }
    }
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum CardType {
    Hunter,
    Brute,
    Magical,
}
