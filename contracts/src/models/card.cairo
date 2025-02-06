#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Card {
    card_id: u64,
    card_name: felt252,
    card_rarity: CardRarity,
    card_cost: u8,
    card_type: CardType,
    creature_card: CreatureCard,
    spell_card: SpellCard,
}

#[derive(Copy, Drop, Serde)]
pub struct CreatureCard {
    attack: u8,
    health: u8,
    creature_type: CreatureType,
    play_effect: CreatureEffect,
    death_effect: CreatureEffect,
    attack_effect: CreatureEffect,
}

#[derive(Copy, Drop, Serde)]
pub struct SpellCard {
    cost: u8,
    play_effect: CardEffect,
}

#[derive(Copy, Drop, Serde)]
pub struct CreatureEffect {
    // Hero
    heal_hero: u8,
    increase_hero_energy: u8,
    // boost allies
    give_all_health: u8,
    give_all_attack: u8,
    give_same_type_attack: u8,
    give_same_type_health: u8,
    // Enemy
    damage_enemy: u8,
    enemy_marks: u8,
    reduce_attack: u8,
    reduce_attack_if_no_same_type_ally: u8,
    heal_hero_if_enemy_weak: u8,
    // Bonus
    attack_if_type_ally: u8,
    health_if_type_ally: u8,
    health_for_each_type_ally: u8,
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum CardType {
    Creature,
    Spell,
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum CardRarity {
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum CreatureType {
    None,
    Hunter,
    Brute,
    Magical,
}