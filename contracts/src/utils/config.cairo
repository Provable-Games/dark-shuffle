use darkshuffle::constants::{DEFAULT_SETTINGS, VERSION};
use darkshuffle::models::card::{
    Card, CardCategory, CardEffect, CardModifier, CardRarity, CardType, CreatureCard, EffectBonus, Modifier,
    Requirement, SpellCard, ValueType,
};
use darkshuffle::models::config::{BattleSettings, CardsCounter, DraftSettings, GameSettings, MapSettings};
use darkshuffle::systems::config::contracts::{IConfigSystemsDispatcher, IConfigSystemsDispatcherTrait};
use darkshuffle::utils::random::{LCG, get_random_number};
use dojo::model::ModelStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};

#[generate_trait]
impl ConfigUtilsImpl of ConfigUtilsTrait {
    fn get_game_settings(world: WorldStorage, game_id: u64) -> GameSettings {
        let (config_systems_address, _) = world.dns(@"config_systems").unwrap();
        let config_systems = IConfigSystemsDispatcher { contract_address: config_systems_address };
        let settings_id: u32 = config_systems.settings_id(game_id);
        let game_settings: GameSettings = world.read_model(settings_id);
        game_settings
    }

    fn random_settings(settings_id: u32, mut seed: u128) -> GameSettings {
        let PERSISTENT_HEALTH: bool = if get_random_number(seed, 2) == 1 {
            true
        } else {
            false
        };

        seed = LCG(seed);
        let AUTO_DRAFT: bool = if get_random_number(seed, 4) == 1 {
            true
        } else {
            false
        };

        seed = LCG(seed);
        let START_ENERGY: u8 = get_random_number(seed, 10);

        seed = LCG(seed);
        let MAX_ENERGY: u8 = get_random_number(seed, START_ENERGY) + 4;

        seed = LCG(seed);
        let START_HAND_SIZE: u8 = get_random_number(seed, 10);

        seed = LCG(seed);
        let mut MAX_HAND_SIZE: u8 = get_random_number(seed, 6) + 4;
        if MAX_HAND_SIZE < START_HAND_SIZE {
            MAX_HAND_SIZE = START_HAND_SIZE;
        }

        seed = LCG(seed);
        let DRAW_AMOUNT: u8 = if get_random_number(seed, 5) == 1 {
            2
        } else {
            1
        };

        seed = LCG(seed);
        let POSSIBLE_BRANCHES: u8 = get_random_number(seed, 3);

        seed = LCG(seed);
        let LEVEL_DEPTH: u8 = get_random_number(seed, 5);

        seed = LCG(seed);
        let ENEMY_ATTACK_MIN: u8 = get_random_number(seed, 5);

        seed = LCG(seed);
        let ENEMY_ATTACK_MAX: u8 = get_random_number(seed, ENEMY_ATTACK_MIN + 2);

        seed = LCG(seed);
        let mut ENEMY_HEALTH_MIN: u8 = get_random_number(seed, 20) + (ENEMY_ATTACK_MIN * 10);

        seed = LCG(seed);
        let ENEMY_HEALTH_MAX: u8 = get_random_number(seed, ENEMY_HEALTH_MIN + 20);

        seed = LCG(seed);
        let DRAFT_SIZE: u8 = get_random_number(seed, 25) + 4;

        seed = LCG(seed);
        let ENEMY_HEALTH_SCALING: u8 = get_random_number(seed, 2);

        seed = LCG(seed);
        let ENEMY_ATTACK_SCALING: u8 = get_random_number(seed, 2);

        seed = LCG(seed);
        let STARTING_HEALTH: u8 = get_random_number(seed, 20) + (ENEMY_ATTACK_MIN * 10);

        if ENEMY_HEALTH_MIN > DRAFT_SIZE * 5 {
            ENEMY_HEALTH_MIN = DRAFT_SIZE * 5;
        }

        GameSettings {
            settings_id: settings_id,
            starting_health: STARTING_HEALTH,
            persistent_health: PERSISTENT_HEALTH,
            map: MapSettings {
                possible_branches: POSSIBLE_BRANCHES,
                level_depth: LEVEL_DEPTH,
                enemy_attack_min: ENEMY_ATTACK_MIN,
                enemy_attack_max: ENEMY_ATTACK_MAX,
                enemy_health_min: ENEMY_HEALTH_MIN,
                enemy_health_max: ENEMY_HEALTH_MAX,
                enemy_health_scaling: ENEMY_HEALTH_SCALING,
                enemy_attack_scaling: ENEMY_ATTACK_SCALING,
            },
            battle: BattleSettings {
                start_energy: START_ENERGY,
                start_hand_size: START_HAND_SIZE,
                max_energy: MAX_ENERGY,
                max_hand_size: MAX_HAND_SIZE,
                draw_amount: DRAW_AMOUNT,
            },
            draft: DraftSettings {
                card_ids: DEFAULT_SETTINGS::GET_GENESIS_CARD_IDS(),
                card_rarity_weights: DEFAULT_SETTINGS::GET_DEFAULT_WEIGHTS(),
                auto_draft: AUTO_DRAFT,
                draft_size: DRAFT_SIZE,
            },
        }
    }

    fn create_creature_card(
        ref world: WorldStorage,
        name: felt252,
        rarity: u8,
        cost: u8,
        attack: u8,
        health: u8,
        card_type: u8,
        play_effect: CardEffect,
        attack_effect: CardEffect,
        death_effect: CardEffect,
    ) {
        let mut cards_count: CardsCounter = world.read_model(VERSION);
        cards_count.count += 1;
        world.write_model(@cards_count);

        let card = Card { id: cards_count.count, name, rarity, cost, category: CardCategory::Creature.into() };
        let creature_card = CreatureCard {
            id: cards_count.count, attack, health, card_type, play_effect, attack_effect, death_effect,
        };

        // Validate the card before writing to storage
        assert(Self::validate_card(card, Option::Some(creature_card), Option::None), 'Invalid creature card');

        world.write_model(@card);
        world.write_model(@creature_card);
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

        let card = Card { id: cards_count.count, name, rarity, cost, category: CardCategory::Spell.into() };
        let spell_card = SpellCard { id: cards_count.count, card_type, effect, extra_effect };

        // Validate the card before writing to storage
        assert(Self::validate_card(card, Option::None, Option::Some(spell_card)), 'Invalid spell card');

        world.write_model(@card);
        world.write_model(@spell_card);
    }

    fn validate_card(card: Card, creature_card: Option<CreatureCard>, spell_card: Option<SpellCard>) -> bool {
        // Validate basic card attributes
        assert!(card.name != 0, "Card name cannot be empty");
        assert!(
            card.rarity > CardRarity::None.into() && card.rarity <= CardRarity::Legendary.into(), "Invalid card rarity",
        );
        assert!(card.cost > 0, "Card cost must be positive");
        assert!(
            card.category > CardCategory::None.into() && card.category <= CardCategory::Spell.into(),
            "Invalid card category",
        );

        // Validate based on card category
        let category: CardCategory = card.category.into();
        match category {
            CardCategory::Creature => {
                // Ensure creature card exists
                assert!(creature_card.is_some(), "Creature card must exist for creature category");
                let creature = creature_card.unwrap();

                // Validate creature card attributes
                assert!(creature.id == card.id, "Creature card ID must match card ID");
                assert!(creature.attack > 0, "Creature attack must be positive");
                assert!(creature.health > 0, "Creature health must be positive");
                assert!(
                    creature.card_type > CardType::None.into() && creature.card_type <= CardType::Magical.into(),
                    "Invalid creature card type",
                );

                // Validate creature card effects
                Self::validate_card_effect(creature.play_effect);
                Self::validate_card_effect(creature.attack_effect);
                Self::validate_card_effect(creature.death_effect);

                true
            },
            CardCategory::Spell => {
                // Ensure spell card exists
                assert!(spell_card.is_some(), "Spell card must exist for spell category");
                let spell = spell_card.unwrap();

                // Validate spell card attributes
                assert!(spell.id == card.id, "Spell card ID must match card ID");
                assert!(
                    spell.card_type > CardType::None.into() && spell.card_type <= CardType::Magical.into(),
                    "Invalid spell card type",
                );

                // Validate spell card effects
                Self::validate_card_effect(spell.effect);
                Self::validate_card_effect(spell.extra_effect);

                true
            },
            _ => false,
        }
    }

    fn validate_card_effect(effect: CardEffect) -> bool {
        // Validate modifier
        assert!(
            effect.modifier._type >= Modifier::None.into() && effect.modifier._type <= Modifier::SelfHealth.into(),
            "Invalid modifier type",
        );
        assert!(
            effect.modifier.value_type >= ValueType::None.into()
                && effect.modifier.value_type <= ValueType::PerAlly.into(),
            "Invalid value type",
        );
        assert!(
            effect.modifier.requirement >= Requirement::None.into()
                && effect.modifier.requirement <= Requirement::NoAlly.into(),
            "Invalid requirement",
        );

        // Validate bonus
        assert!(
            effect.bonus.requirement >= Requirement::None.into()
                && effect.bonus.requirement <= Requirement::NoAlly.into(),
            "Invalid bonus requirement",
        );

        true
    }

    fn create_genesis_cards(ref world: WorldStorage) {
        // Card 1: Warlock
        Self::create_creature_card(
            ref world,
            'Warlock',
            CardRarity::Legendary.into(),
            3,
            3,
            4,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(), value: 2, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
        );

        // Card 2: Typhon
        Self::create_creature_card(
            ref world,
            'Typhon',
            CardRarity::Legendary.into(),
            5,
            5,
            5,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfHealth.into(), value: 1, value_type: ValueType::PerAlly.into(), requirement: 0,
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
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(), value: 2, value_type: ValueType::Fixed.into(), requirement: 0,
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
                    _type: Modifier::AllAttack.into(), value: 2, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
        );

        // Card 5: Basilisk
        Self::create_creature_card(
            ref world,
            'Basilisk',
            CardRarity::Legendary.into(),
            1,
            3,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 6: Griffin
        Self::create_creature_card(
            ref world,
            'Griffin',
            CardRarity::Legendary.into(),
            4,
            5,
            4,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
                    _type: Modifier::EnemyMarks.into(), value: 2, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(), value: 1, value_type: ValueType::PerAlly.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
                    _type: Modifier::EnemyHealth.into(), value: 2, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 2, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 10: Minotaur
        Self::create_creature_card(
            ref world,
            'Minotaur',
            CardRarity::Legendary.into(),
            3,
            5,
            4,
            CardType::Hunter.into(),
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
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
                    _type: Modifier::AllyAttack.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
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
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 15: Tarrasque
        Self::create_creature_card(
            ref world,
            'Tarrasque',
            CardRarity::Legendary.into(),
            1,
            3,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
        );

        // Card 16: Gorgon
        Self::create_creature_card(
            ref world,
            'Gorgon',
            CardRarity::Epic.into(),
            3,
            3,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 17: Kitsune
        Self::create_creature_card(
            ref world,
            'Kitsune',
            CardRarity::Epic.into(),
            2,
            3,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::HasAlly.into() },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 18: Lich
        Self::create_creature_card(
            ref world,
            'Lich',
            CardRarity::Epic.into(),
            4,
            3,
            4,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 19: Chimera
        Self::create_creature_card(
            ref world,
            'Chimera',
            CardRarity::Epic.into(),
            3,
            3,
            4,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(), value: 2, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 20: Wendigo
        Self::create_creature_card(
            ref world,
            'Wendigo',
            CardRarity::Epic.into(),
            2,
            2,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 21: Qilin
        Self::create_creature_card(
            ref world,
            'Qilin',
            CardRarity::Epic.into(),
            1,
            3,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 22: Ammit
        Self::create_creature_card(
            ref world,
            'Ammit',
            CardRarity::Epic.into(),
            3,
            5,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::NoAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 23: Nue
        Self::create_creature_card(
            ref world,
            'Nue',
            CardRarity::Epic.into(),
            2,
            4,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::HasAlly.into() },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 24: Skinwalker
        Self::create_creature_card(
            ref world,
            'Skinwalker',
            CardRarity::Epic.into(),
            4,
            4,
            3,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyMarks.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 25: Chupacabra
        Self::create_creature_card(
            ref world,
            'Chupacabra',
            CardRarity::Epic.into(),
            2,
            2,
            3,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::NextAllyAttack.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::EnemyWeak.into() },
            },
        );

        // Card 26: Titan
        Self::create_creature_card(
            ref world,
            'Titan',
            CardRarity::Epic.into(),
            2,
            2,
            5,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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

        // Card 27: Nephilim
        Self::create_creature_card(
            ref world,
            'Nephilim',
            CardRarity::Epic.into(),
            3,
            4,
            4,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 28: Behemoth
        Self::create_creature_card(
            ref world,
            'Behemoth',
            CardRarity::Epic.into(),
            3,
            4,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 29: Hydra
        Self::create_creature_card(
            ref world,
            'Hydra',
            CardRarity::Epic.into(),
            1,
            3,
            2,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::NextAllyHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 30: Juggernaut
        Self::create_creature_card(
            ref world,
            'Juggernaut',
            CardRarity::Epic.into(),
            3,
            3,
            4,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::NextAllyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 31: Rakshasa
        Self::create_creature_card(
            ref world,
            'Rakshasa',
            CardRarity::Rare.into(),
            4,
            4,
            4,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyHealth.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 32: Werewolf
        Self::create_creature_card(
            ref world,
            'Werewolf',
            CardRarity::Rare.into(),
            2,
            3,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 33: Banshee
        Self::create_creature_card(
            ref world,
            'Banshee',
            CardRarity::Rare.into(),
            4,
            3,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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

        // Card 34: Draugr
        Self::create_creature_card(
            ref world,
            'Draugr',
            CardRarity::Rare.into(),
            1,
            2,
            2,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 35: Vampire
        Self::create_creature_card(
            ref world,
            'Vampire',
            CardRarity::Rare.into(),
            4,
            4,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::NoAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 36: Weretiger
        Self::create_creature_card(
            ref world,
            'Weretiger',
            CardRarity::Rare.into(),
            5,
            6,
            3,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyMarks.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 37: Wyvern
        Self::create_creature_card(
            ref world,
            'Wyvern',
            CardRarity::Rare.into(),
            1,
            3,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 38: Roc
        Self::create_creature_card(
            ref world,
            'Roc',
            CardRarity::Rare.into(),
            4,
            5,
            4,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::NextAllyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: 0,
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::EnemyWeak.into() },
            },
        );

        // Card 39: Harpy
        Self::create_creature_card(
            ref world,
            'Harpy',
            CardRarity::Rare.into(),
            2,
            3,
            3,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 40: Pegasus
        Self::create_creature_card(
            ref world,
            'Pegasus',
            CardRarity::Rare.into(),
            3,
            4,
            3,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 41: Oni
        Self::create_creature_card(
            ref world,
            'Oni',
            CardRarity::Rare.into(),
            3,
            3,
            5,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 42: Jotunn
        Self::create_creature_card(
            ref world,
            'Jotunn',
            CardRarity::Rare.into(),
            2,
            3,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 43: Ettin
        Self::create_creature_card(
            ref world,
            'Ettin',
            CardRarity::Rare.into(),
            5,
            6,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 44: Cyclops
        Self::create_creature_card(
            ref world,
            'Cyclops',
            CardRarity::Rare.into(),
            4,
            3,
            4,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 45: Giant
        Self::create_creature_card(
            ref world,
            'Giant',
            CardRarity::Rare.into(),
            1,
            2,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 1, requirement: Requirement::NoAlly.into() },
            },
        );

        // Card 46: Goblin
        Self::create_creature_card(
            ref world,
            'Goblin',
            CardRarity::Uncommon.into(),
            2,
            2,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 47: Ghoul
        Self::create_creature_card(
            ref world,
            'Ghoul',
            CardRarity::Uncommon.into(),
            2,
            2,
            2,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 48: Wraith
        Self::create_creature_card(
            ref world,
            'Wraith',
            CardRarity::Uncommon.into(),
            3,
            3,
            2,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroHealth.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 49: Sprite
        Self::create_creature_card(
            ref world,
            'Sprite',
            CardRarity::Uncommon.into(),
            2,
            2,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 50: Kappa
        Self::create_creature_card(
            ref world,
            'Kappa',
            CardRarity::Uncommon.into(),
            4,
            4,
            4,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 51: Hippogriff
        Self::create_creature_card(
            ref world,
            'Hippogriff',
            CardRarity::Uncommon.into(),
            1,
            3,
            1,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 52: Fenrir
        Self::create_creature_card(
            ref world,
            'Fenrir',
            CardRarity::Uncommon.into(),
            2,
            2,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::NoAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 53: Jaguar
        Self::create_creature_card(
            ref world,
            'Jaguar',
            CardRarity::Uncommon.into(),
            3,
            4,
            3,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::NextAllyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 54: Satori
        Self::create_creature_card(
            ref world,
            'Satori',
            CardRarity::Uncommon.into(),
            4,
            4,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyMarks.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 55: Direwolf
        Self::create_creature_card(
            ref world,
            'Direwolf',
            CardRarity::Uncommon.into(),
            2,
            2,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 56: Nemeanlion
        Self::create_creature_card(
            ref world,
            'Nemeanlion',
            CardRarity::Uncommon.into(),
            3,
            3,
            4,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 57: Berserker
        Self::create_creature_card(
            ref world,
            'Berserker',
            CardRarity::Uncommon.into(),
            2,
            3,
            2,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 58: Yeti
        Self::create_creature_card(
            ref world,
            'Yeti',
            CardRarity::Uncommon.into(),
            1,
            3,
            2,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 59: Golem
        Self::create_creature_card(
            ref world,
            'Golem',
            CardRarity::Uncommon.into(),
            4,
            4,
            2,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 60: Ent
        Self::create_creature_card(
            ref world,
            'Ent',
            CardRarity::Uncommon.into(),
            2,
            2,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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

        // Card 61: Fairy
        Self::create_creature_card(
            ref world,
            'Fairy',
            CardRarity::Common.into(),
            4,
            3,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 62: Leprechaun
        Self::create_creature_card(
            ref world,
            'Leprechaun',
            CardRarity::Common.into(),
            2,
            2,
            2,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 63: Kelpie
        Self::create_creature_card(
            ref world,
            'Kelpie',
            CardRarity::Common.into(),
            1,
            1,
            1,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 2,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 64: Pixie
        Self::create_creature_card(
            ref world,
            'Pixie',
            CardRarity::Common.into(),
            3,
            2,
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
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

        // Card 65: Gnome
        Self::create_creature_card(
            ref world,
            'Gnome',
            CardRarity::Common.into(),
            5,
            4,
            4,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 66: Bear
        Self::create_creature_card(
            ref world,
            'Bear',
            CardRarity::Common.into(),
            4,
            3,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 67: Wolf
        Self::create_creature_card(
            ref world,
            'Wolf',
            CardRarity::Common.into(),
            2,
            2,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 68: Mantis
        Self::create_creature_card(
            ref world,
            'Mantis',
            CardRarity::Common.into(),
            1,
            1,
            1,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::NextAllyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 69: Spider
        Self::create_creature_card(
            ref world,
            'Spider',
            CardRarity::Common.into(),
            3,
            3,
            2,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 70: Rat
        Self::create_creature_card(
            ref world,
            'Rat',
            CardRarity::Common.into(),
            5,
            4,
            4,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::SelfAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 71: Troll
        Self::create_creature_card(
            ref world,
            'Troll',
            CardRarity::Common.into(),
            4,
            3,
            4,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 72: Bigfoot
        Self::create_creature_card(
            ref world,
            'Bigfoot',
            CardRarity::Common.into(),
            2,
            3,
            2,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 73: Ogre
        Self::create_creature_card(
            ref world,
            'Ogre',
            CardRarity::Common.into(),
            1,
            1,
            2,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 74: Orc
        Self::create_creature_card(
            ref world,
            'Orc',
            CardRarity::Common.into(),
            4,
            2,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::EnemyWeak.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 75: Skeleton
        Self::create_creature_card(
            ref world,
            'Skeleton',
            CardRarity::Common.into(),
            5,
            4,
            3,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(),
                    value: 1,
                    value_type: ValueType::Fixed.into(),
                    requirement: Requirement::HasAlly.into(),
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 76: Warlock Pact
        Self::create_spell_card(
            ref world,
            'Warlock Pact',
            CardRarity::Legendary.into(),
            1,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroEnergy.into(), value: 3, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 77: Dragon Breath
        Self::create_spell_card(
            ref world,
            'Dragon Breath',
            CardRarity::Legendary.into(),
            1,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(), value: 4, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 4, requirement: Requirement::EnemyWeak.into() },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 78: Jiangshi Curse
        Self::create_spell_card(
            ref world,
            'Jiangshi Curse',
            CardRarity::Legendary.into(),
            2,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyMarks.into(), value: 2, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 79: Gorgon Gaze
        Self::create_spell_card(
            ref world,
            'Gorgon Gaze',
            CardRarity::Epic.into(),
            3,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyAttack.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 80: Titan Call
        Self::create_spell_card(
            ref world,
            'Titan Call',
            CardRarity::Epic.into(),
            1,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyAttack.into(), value: 3, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 81: Wendigo Frenzy
        Self::create_spell_card(
            ref world,
            'Wendigo Frenzy',
            CardRarity::Epic.into(),
            2,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllAttack.into(), value: 3, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 82: Giant Shoulders
        Self::create_spell_card(
            ref world,
            'Giant Shoulders',
            CardRarity::Rare.into(),
            2,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroHealth.into(), value: 1, value_type: ValueType::PerAlly.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 83: Werewolf Howl
        Self::create_spell_card(
            ref world,
            'Werewolf Howl',
            CardRarity::Rare.into(),
            3,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyStats.into(), value: 3, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 84: Vampire Bite
        Self::create_spell_card(
            ref world,
            'Vampire Bite',
            CardRarity::Rare.into(),
            5,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(), value: 3, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroHealth.into(), value: 3, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 85: Wraith Shadow
        Self::create_spell_card(
            ref world,
            'Wraith Shadow',
            CardRarity::Uncommon.into(),
            1,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::EnemyHealth.into(), value: 4, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 86: Sprite Favor
        Self::create_spell_card(
            ref world,
            'Sprite Favor',
            CardRarity::Uncommon.into(),
            5,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::HeroHealth.into(), value: 4, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 87: Kappa Gift
        Self::create_spell_card(
            ref world,
            'Kappa Gift',
            CardRarity::Uncommon.into(),
            1,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllHealth.into(), value: 2, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 88: Ogre Strength
        Self::create_spell_card(
            ref world,
            'Ogre Strength',
            CardRarity::Common.into(),
            1,
            CardType::Brute.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyStats.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 89: Kitsune Blessing
        Self::create_spell_card(
            ref world,
            'Kitsune Blessing',
            CardRarity::Common.into(),
            1,
            CardType::Magical.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyStats.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );

        // Card 90: Bear Foot
        Self::create_spell_card(
            ref world,
            'Bear Foot',
            CardRarity::Common.into(),
            1,
            CardType::Hunter.into(),
            CardEffect {
                modifier: CardModifier {
                    _type: Modifier::AllyStats.into(), value: 1, value_type: ValueType::Fixed.into(), requirement: 0,
                },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
            CardEffect {
                modifier: CardModifier { _type: 0, value: 0, value_type: 0, requirement: 0 },
                bonus: EffectBonus { value: 0, requirement: 0 },
            },
        );
    }
}
