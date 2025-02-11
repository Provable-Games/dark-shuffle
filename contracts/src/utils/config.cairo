use darkshuffle::constants::{WORLD_CONFIG_ID};
use darkshuffle::interface::{IGameTokenDispatcher, IGameTokenDispatcherTrait};
use darkshuffle::models::config::{WorldConfig, GameSettings};
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use darkshuffle::models::card::{Card, CardRarity, CardDetails, CardType, CreatureCard, SpellCard, CardEffect, CardModifier, Modifier, Requirement, ValueType};

#[generate_trait]
impl ConfigUtilsImpl of ConfigUtilsTrait {
    fn get_game_settings(world: WorldStorage, game_id: u64) -> GameSettings {
        let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
        let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };
        let game_settings: GameSettings = world.read_model(game_token.settings_id(game_id.into()));
        game_settings
    }

    fn create_genesis_cards(ref world: WorldStorage) {
        world.write_model(@Card {
            id: 1,
            name: 'Warlock',
            rarity: CardRarity::Legendary,
            cost: 2,
            card_type: CardType::Magical,
            card_details: CardDetails::creature_card(CreatureCard {
                attack: 3,
                health: 4,
                play_effect: Option::Some(CardEffect {
                    modifier: CardModifier {
                        _type: Modifier::AllAttack,
                        value: 2,
                        value_type: ValueType::Fixed,
                        requirement: Option::None,
                    },
                    bonus: Option::None,
                }),
                death_effect: Option::Some(CardEffect {
                    modifier: CardModifier {
                        _type: Modifier::EnemyAttack,
                        value: 1,
                        value_type: ValueType::Fixed,
                        requirement: Option::None,
                    },
                    bonus: Option::None,
                }),
                attack_effect: Option::None,
            }),
        });

        world.write_model(@Card {
            id: 2,
            name: 'Typhon',
            rarity: CardRarity::Legendary,
            cost: 5,
            card_type: CardType::Magical,
            card_details: CardDetails::creature_card(CreatureCard {
                attack: 6,
                health: 6,
                play_effect: Option::Some(CardEffect {
                    modifier: CardModifier {
                        _type: Modifier::SelfHealth,
                        value: 1,
                        value_type: ValueType::PerAlly,
                        requirement: Option::None,
                    },
                    bonus: Option::None,
                }),
                attack_effect: Option::Some(CardEffect {
                    modifier: CardModifier {
                        _type: Modifier::HeroHealth,
                        value: 2,
                        value_type: ValueType::Fixed,
                        requirement: Option::Some(Requirement::EnemyWeak),
                    },
                    bonus: Option::None,
                }),
                death_effect: Option::None,
            }),
        });
    }
}
