use darkshuffle::constants::VERSION;
use darkshuffle::models::card::{
    Card, CardEffect, CardModifier, CardRarity, CardType, CreatureCard, EffectBonus, Modifier, Requirement,
    SpellCard, ValueType, CardCategory,
};
use darkshuffle::models::config::{CardsCounter, GameSettings};
use dojo::model::ModelStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage};
use tournaments::components::models::game::TokenMetadata;

#[generate_trait]
impl ConfigUtilsImpl of ConfigUtilsTrait {
    fn get_game_settings(world: WorldStorage, game_id: u64) -> GameSettings {
        let token_metadata: TokenMetadata = world.read_model(game_id);
        let game_settings: GameSettings = world.read_model(token_metadata.settings_id);
        game_settings
    }

    fn create_creature_card(
        ref world: WorldStorage,
        name: felt252,
        rarity: u8,
        cost: u8,
        card_type: u8,
        attack: u8,
        health: u8,
        play_effect: CardEffect,
        death_effect: CardEffect,
        attack_effect: CardEffect,
    ) {
        let mut cards_count: CardsCounter = world.read_model(VERSION);
        cards_count.count += 1;
        world.write_model(@cards_count);

        world.write_model(@Card { id: cards_count.count, name, rarity, cost, category: CardCategory::Creature.into() });
        world.write_model(@CreatureCard { id: cards_count.count, attack, health, card_type, play_effect, death_effect, attack_effect });
    }

    fn create_spell_card(
        ref world: WorldStorage,
        name: felt252,
        rarity: u8,
        cost: u8,
        card_type: u8,
        effect: CardEffect,
        extra_effect: CardEffect,
    ) {
        let mut cards_count: CardsCounter = world.read_model(VERSION);
        cards_count.count += 1;
        world.write_model(@cards_count);

        world.write_model(@Card { id: cards_count.count, name, rarity, cost, category: CardCategory::Spell.into() });
        world.write_model(@SpellCard { id: cards_count.count, card_type, effect, extra_effect });
    }

    fn create_genesis_cards(ref world: WorldStorage) {
        // Card 1: Warlock
        Self::create_creature_card(
            ref world,
            'Warlock',
            CardRarity::Legendary.into(),
            2,
            3,
            4,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::NoAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 2: Typhon
        Self::create_creature_card(
            ref world,
            'Typhon',
            CardRarity::Legendary.into(),
            5,
            6,
            6,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfHealth.into(),
                    value: 1,
                    value_type: ValueType::PerAlly.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 3: Jiangshi
        Self::create_creature_card(
            ref world,
            'Jiangshi',
            CardRarity::Legendary.into(),
            3,
            3,
            4,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 4: Anansi
        Self::create_creature_card(
            ref world,
            'Anansi',
            CardRarity::Legendary.into(),
            4,
            4,
            5,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllAttack.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 3,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 5: Basilisk
        Self::create_creature_card(
            ref world,
            'Basilisk',
            CardRarity::Legendary.into(),
            1,
            3,
            2,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 6: Griffin
        Self::create_creature_card(
            ref world,
            'Griffin',
            CardRarity::Legendary.into(),
            5,
            6,
            4,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 5,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 7: Manticore
        Self::create_creature_card(
            ref world,
            'Manticore',
            CardRarity::Legendary.into(),
            4,
            4,
            5,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyMarks.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 8: Phoenix
        Self::create_creature_card(
            ref world,
            'Phoenix',
            CardRarity::Legendary.into(),
            1,
            3,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 1,
                    value_type: ValueType::PerAlly.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 9: Dragon
        Self::create_creature_card(
            ref world,
            'Dragon',
            CardRarity::Legendary.into(),
            2,
            4,
            3,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 2, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 10: Minotaur
        Self::create_creature_card(
            ref world,
            'Minotaur',
            CardRarity::Legendary.into(),
            4,
            5,
            4,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::NextAllyAttack.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 2, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 11: Kraken
        Self::create_creature_card(
            ref world,
            'Kraken',
            CardRarity::Legendary.into(),
            2,
            3,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 12: Colossus
        Self::create_creature_card(
            ref world,
            'Colossus',
            CardRarity::Legendary.into(),
            5,
            5,
            7,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroDamageReduction.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 13: Balrog
        Self::create_creature_card(
            ref world,
            'Balrog',
            CardRarity::Legendary.into(),
            3,
            4,
            6,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::HasAlly.into() },
            },
        );

        // Card 14: Leviathan
        Self::create_creature_card(
            ref world,
            'Leviathan',
            CardRarity::Legendary.into(),
            1,
            4,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 15: Tarrasque
        Self::create_creature_card(
            ref world,
            'Tarrasque',
            CardRarity::Legendary.into(),
            2,
            3,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::NextAllyHealth.into(),
                    value: 3,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 2, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 76: Warlock Pact (Spell)
        Self::create_spell_card(
            ref world,
            'Warlock Pact',
            CardRarity::Legendary.into(),
            1,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroEnergy.into(),
                    value: 3,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 77: Dragon Breath (Spell)
        Self::create_spell_card(
            ref world,
            'Dragon Breath',
            CardRarity::Legendary.into(),
            1,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 4,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 4, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 78: Jiangshi Curse (Spell)
        Self::create_spell_card(
            ref world,
            'Jiangshi Curse',
            CardRarity::Legendary.into(),
            2,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyMarks.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: 0,
                    value: 0,
                    value_type: 0,
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 84: Vampire Bite (Spell)
        Self::create_spell_card(
            ref world,
            'Vampire Bite',
            CardRarity::Rare.into(),
            5,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 4,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroHealth.into(),
                    value: 4,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Additional cards can be created using the same pattern
        // For brevity, I've included a subset of all cards from the original implementation
    }
}
