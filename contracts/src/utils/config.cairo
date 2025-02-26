use darkshuffle::constants::{VERSION};
use darkshuffle::models::card::{
    Card, CardRarity, CardDetails, CardType, CreatureCard, SpellCard, CardEffect, CardModifier, Modifier, Requirement,
    ValueType, EffectBonus
};
use darkshuffle::models::config::{GameSettings, CardsCounter};
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use tournaments::components::models::game::TokenMetadata;

#[generate_trait]
impl ConfigUtilsImpl of ConfigUtilsTrait {
    fn get_game_settings(world: WorldStorage, game_id: u64) -> GameSettings {
        let token_metadata: TokenMetadata = world.read_model(game_id);
        let game_settings: GameSettings = world.read_model(token_metadata.settings_id);
        game_settings
    }

    fn create_card(
        ref world: WorldStorage,
        name: felt252,
        rarity: CardRarity,
        cost: u8,
        card_type: CardType,
        card_details: CardDetails
    ) {
        // increment cards counter
        let mut cards_count: CardsCounter = world.read_model(VERSION);
        cards_count.count += 1;
        world.write_model(@cards_count);

        world.write_model(@Card { id: cards_count.count, name, rarity, cost, card_type, card_details, });
    }

    fn create_genesis_cards(ref world: WorldStorage) {
        // Card 1: Warlock
        Self::create_card(
            ref world,
            'Warlock',
            CardRarity::Legendary,
            2,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 4,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllyAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::NoAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 2: Typhon
        Self::create_card(
            ref world,
            'Typhon',
            CardRarity::Legendary,
            5,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 6,
                    health: 6,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfHealth,
                                value: 1,
                                value_type: ValueType::PerAlly,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 3: Jiangshi
        Self::create_card(
            ref world,
            'Jiangshi',
            CardRarity::Legendary,
            3,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 5,
                    health: 4,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllyAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 4: Anansi
        Self::create_card(
            ref world,
            'Anansi',
            CardRarity::Legendary,
            4,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 5,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 3,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 5: Basilisk
        Self::create_card(
            ref world,
            'Basilisk',
            CardRarity::Legendary,
            1,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 6: Griffin
        Self::create_card(
            ref world,
            'Griffin',
            CardRarity::Legendary,
            5,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 6,
                    health: 4,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 5,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 7: Manticore
        Self::create_card(
            ref world,
            'Manticore',
            CardRarity::Legendary,
            4,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 5,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::Some(EffectBonus { value: 1, requirement: Requirement::EnemyWeak, }),
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 8: Phoenix
        Self::create_card(
            ref world,
            'Phoenix',
            CardRarity::Legendary,
            1,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 1,
                                value_type: ValueType::PerAlly,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 9: Dragon
        Self::create_card(
            ref world,
            'Dragon',
            CardRarity::Legendary,
            2,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::Some(EffectBonus { value: 2, requirement: Requirement::EnemyWeak, }),
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 10: Minotaur
        Self::create_card(
            ref world,
            'Minotaur',
            CardRarity::Legendary,
            4,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 5,
                    health: 4,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::NextAllyAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::Some(EffectBonus { value: 2, requirement: Requirement::EnemyWeak, }),
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 11: Kraken
        Self::create_card(
            ref world,
            'Kraken',
            CardRarity::Legendary,
            2,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 12: Colossus
        Self::create_card(
            ref world,
            'Colossus',
            CardRarity::Legendary,
            5,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 5,
                    health: 7,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroDamageReduction,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 13: Balrog
        Self::create_card(
            ref world,
            'Balrog',
            CardRarity::Legendary,
            3,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 6,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::Some(EffectBonus { value: 1, requirement: Requirement::HasAlly, }),
                        }
                    ),
                }
            )
        );

        // Card 14: Leviathan
        Self::create_card(
            ref world,
            'Leviathan',
            CardRarity::Legendary,
            1,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 15: Tarrasque
        Self::create_card(
            ref world,
            'Tarrasque',
            CardRarity::Legendary,
            2,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::NextAllyHealth,
                                value: 3,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::Some(EffectBonus { value: 2, requirement: Requirement::EnemyWeak, }),
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 16: Gorgon
        Self::create_card(
            ref world,
            'Gorgon',
            CardRarity::Epic,
            2,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 17: Kitsune
        Self::create_card(
            ref world,
            'Kitsune',
            CardRarity::Epic,
            4,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::Some(EffectBonus { value: 1, requirement: Requirement::HasAlly, }),
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 18: Lich
        Self::create_card(
            ref world,
            'Lich',
            CardRarity::Epic,
            3,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 4,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 19: Chimera
        Self::create_card(
            ref world,
            'Chimera',
            CardRarity::Epic,
            3,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 4,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 20: Wendigo
        Self::create_card(
            ref world,
            'Wendigo',
            CardRarity::Epic,
            2,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 21: Qilin
        Self::create_card(
            ref world,
            'Qilin',
            CardRarity::Epic,
            1,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 22: Ammit
        Self::create_card(
            ref world,
            'Ammit',
            CardRarity::Epic,
            4,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 5,
                    health: 2,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::NoAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 23: Nue
        Self::create_card(
            ref world,
            'Nue',
            CardRarity::Epic,
            3,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::Some(EffectBonus { value: 1, requirement: Requirement::HasAlly, }),
                        }
                    ),
                }
            )
        );

        // Card 24: Skinwalker
        Self::create_card(
            ref world,
            'Skinwalker',
            CardRarity::Epic,
            5,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::Some(EffectBonus { value: 1, requirement: Requirement::EnemyWeak, }),
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 25: Chupacabra
        Self::create_card(
            ref world,
            'Chupacabra',
            CardRarity::Epic,
            2,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::NextAllyAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::Some(EffectBonus { value: 1, requirement: Requirement::EnemyWeak, }),
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 26: Titan
        Self::create_card(
            ref world,
            'Titan',
            CardRarity::Epic,
            2,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 5,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 27: Nephilim
        Self::create_card(
            ref world,
            'Nephilim',
            CardRarity::Epic,
            4,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 4,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 28: Behemoth
        Self::create_card(
            ref world,
            'Behemoth',
            CardRarity::Epic,
            3,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 29: Hydra
        Self::create_card(
            ref world,
            'Hydra',
            CardRarity::Epic,
            1,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::NextAllyHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 30: Juggernaut
        Self::create_card(
            ref world,
            'Juggernaut',
            CardRarity::Epic,
            4,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 4,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::NextAllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 31: Rakshasa
        Self::create_card(
            ref world,
            'Rakshasa',
            CardRarity::Epic,
            3,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 4,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 32: Werewolf
        Self::create_card(
            ref world,
            'Werewolf',
            CardRarity::Epic,
            2,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 33: Banshee
        Self::create_card(
            ref world,
            'Banshee',
            CardRarity::Epic,
            4,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 34: Draugr
        Self::create_card(
            ref world,
            'Draugr',
            CardRarity::Epic,
            1,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 2,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 35: Vampire
        Self::create_card(
            ref world,
            'Vampire',
            CardRarity::Epic,
            4,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::NoAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 36: Weretiger
        Self::create_card(
            ref world,
            'Weretiger',
            CardRarity::Epic,
            5,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 6,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 37: Wyvern
        Self::create_card(
            ref world,
            'Wyvern',
            CardRarity::Epic,
            1,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 38: Roc
        Self::create_card(
            ref world,
            'Roc',
            CardRarity::Epic,
            4,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 4,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::NextAllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::Some(EffectBonus { value: 1, requirement: Requirement::EnemyWeak, }),
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 39: Harpy
        Self::create_card(
            ref world,
            'Harpy',
            CardRarity::Epic,
            2,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 40: Pegasus
        Self::create_card(
            ref world,
            'Pegasus',
            CardRarity::Epic,
            3,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 41: Oni
        Self::create_card(
            ref world,
            'Oni',
            CardRarity::Epic,
            3,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 5,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 42: Jotunn
        Self::create_card(
            ref world,
            'Jotunn',
            CardRarity::Epic,
            2,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::Some(EffectBonus { value: 1, requirement: Requirement::EnemyWeak, }),
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 43: Ettin
        Self::create_card(
            ref world,
            'Ettin',
            CardRarity::Epic,
            5,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 5,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 44: Cyclops
        Self::create_card(
            ref world,
            'Cyclops',
            CardRarity::Epic,
            4,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 4,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 45: Giant
        Self::create_card(
            ref world,
            'Giant',
            CardRarity::Epic,
            1,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::Some(EffectBonus { value: 1, requirement: Requirement::NoAlly, }),
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 46: Goblin
        Self::create_card(
            ref world,
            'Goblin',
            CardRarity::Epic,
            2,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 47: Ghoul
        Self::create_card(
            ref world,
            'Ghoul',
            CardRarity::Epic,
            1,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 2,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 48: Wraith
        Self::create_card(
            ref world,
            'Wraith',
            CardRarity::Epic,
            3,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 49: Sprite
        Self::create_card(
            ref world,
            'Sprite',
            CardRarity::Epic,
            2,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 50: Kappa
        Self::create_card(
            ref world,
            'Kappa',
            CardRarity::Epic,
            4,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 51: Hippogriff
        Self::create_card(
            ref world,
            'Hippogriff',
            CardRarity::Epic,
            1,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 1,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 52: Fenrir
        Self::create_card(
            ref world,
            'Fenrir',
            CardRarity::Epic,
            2,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 2,
                    death_effect: Option::None,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::NoAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 53: Jaguar
        Self::create_card(
            ref world,
            'Jaguar',
            CardRarity::Epic,
            3,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::NextAllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 54: Satori
        Self::create_card(
            ref world,
            'Satori',
            CardRarity::Epic,
            4,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 2,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 55: Direwolf
        Self::create_card(
            ref world,
            'Direwolf',
            CardRarity::Epic,
            2,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 56: Nemeanlion
        Self::create_card(
            ref world,
            'Nemeanlion',
            CardRarity::Epic,
            3,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 4,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 57: Berserker
        Self::create_card(
            ref world,
            'Berserker',
            CardRarity::Epic,
            2,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 58: Yeti
        Self::create_card(
            ref world,
            'Yeti',
            CardRarity::Epic,
            1,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 59: Golem
        Self::create_card(
            ref world,
            'Golem',
            CardRarity::Epic,
            4,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 2,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 60: Ent
        Self::create_card(
            ref world,
            'Ent',
            CardRarity::Epic,
            2,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 61: Fairy
        Self::create_card(
            ref world,
            'Fairy',
            CardRarity::Epic,
            4,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 62: Leprechaun
        Self::create_card(
            ref world,
            'Leprechaun',
            CardRarity::Epic,
            2,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 63: Kelpie
        Self::create_card(
            ref world,
            'Kelpie',
            CardRarity::Epic,
            1,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 1,
                    health: 1,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 64: Pixie
        Self::create_card(
            ref world,
            'Pixie',
            CardRarity::Epic,
            3,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 65: Gnome
        Self::create_card(
            ref world,
            'Gnome',
            CardRarity::Epic,
            5,
            CardType::Magical,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 66: Bear
        Self::create_card(
            ref world,
            'Bear',
            CardRarity::Epic,
            4,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 67: Wolf
        Self::create_card(
            ref world,
            'Wolf',
            CardRarity::Epic,
            2,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 68: Mantis
        Self::create_card(
            ref world,
            'Mantis',
            CardRarity::Epic,
            1,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 1,
                    health: 1,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::NextAllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 69: Spider
        Self::create_card(
            ref world,
            'Spider',
            CardRarity::Epic,
            3,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 70: Rat
        Self::create_card(
            ref world,
            'Rat',
            CardRarity::Epic,
            5,
            CardType::Hunter,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 4,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::SelfAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 71: Troll
        Self::create_card(
            ref world,
            'Troll',
            CardRarity::Epic,
            4,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 4,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 72: Bigfoot
        Self::create_card(
            ref world,
            'Bigfoot',
            CardRarity::Epic,
            2,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 2,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 73: Ogre
        Self::create_card(
            ref world,
            'Ogre',
            CardRarity::Epic,
            1,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 1,
                    health: 2,
                    play_effect: Option::None,
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            )
        );

        // Card 74: Orc
        Self::create_card(
            ref world,
            'Orc',
            CardRarity::Epic,
            3,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 2,
                    health: 3,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::EnemyWeak),
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::None,
                    attack_effect: Option::None,
                }
            )
        );

        // Card 75: Skeleton
        Self::create_card(
            ref world,
            'Skeleton',
            CardRarity::Epic,
            5,
            CardType::Brute,
            CardDetails::creature_card(
                CreatureCard {
                    attack: 4,
                    health: 3,
                    play_effect: Option::None,
                    death_effect: Option::None,
                    attack_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyHealth,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::Some(Requirement::HasAlly),
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 76: Warlock Pact
        Self::create_card(
            ref world,
            'Warlock Pact',
            CardRarity::Legendary,
            1,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::HeroEnergy,
                            value: 3,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 77: Dragon Breath
        Self::create_card(
            ref world,
            'Dragon Breath',
            CardRarity::Legendary,
            1,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::EnemyHealth,
                            value: 4,
                            value_type: ValueType::Fixed,
                            requirement: Option::Some(Requirement::EnemyWeak),
                        },
                        bonus: Option::Some(EffectBonus { value: 4, requirement: Requirement::EnemyWeak, }),
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 78: Jiangshi Curse
        Self::create_card(
            ref world,
            'Jiangshi Curse',
            CardRarity::Legendary,
            2,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::EnemyMarks,
                            value: 2,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 79: Gorgon Gaze
        Self::create_card(
            ref world,
            'Gorgon Gaze',
            CardRarity::Epic,
            2,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::EnemyAttack,
                            value: 1,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 80: Titan Call
        Self::create_card(
            ref world,
            'Titan Call',
            CardRarity::Epic,
            1,
            CardType::Brute,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::AllyAttack,
                            value: 3,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 81: Wendigo Frenzy
        Self::create_card(
            ref world,
            'Wendigo Frenzy',
            CardRarity::Epic,
            2,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::AllAttack,
                            value: 3,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 82: Giant Shoulders
        Self::create_card(
            ref world,
            'Giant Shoulders',
            CardRarity::Rare,
            2,
            CardType::Brute,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::HeroHealth,
                            value: 1,
                            value_type: ValueType::PerAlly,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 83: Werewolf Howl
        Self::create_card(
            ref world,
            'Werewolf Howl',
            CardRarity::Rare,
            3,
            CardType::Hunter,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::AllyStats,
                            value: 3,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 84: Vampire Bite
        Self::create_card(
            ref world,
            'Vampire Bite',
            CardRarity::Rare,
            5,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::EnemyHealth,
                            value: 4,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::HeroHealth,
                                value: 4,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                }
            )
        );

        // Card 85: Wraith Shadow
        Self::create_card(
            ref world,
            'Wraith Shadow',
            CardRarity::Uncommon,
            1,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::EnemyHealth,
                            value: 4,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 86: Sprite Favor
        Self::create_card(
            ref world,
            'Sprite Favor',
            CardRarity::Uncommon,
            5,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::HeroHealth,
                            value: 5,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 87: Kappa Gift
        Self::create_card(
            ref world,
            'Kappa Gift',
            CardRarity::Uncommon,
            2,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::AllHealth,
                            value: 2,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 88: Ogre Strength
        Self::create_card(
            ref world,
            'Ogre Strength',
            CardRarity::Common,
            1,
            CardType::Brute,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::AllyStats,
                            value: 1,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 89: Kitsune Blessing
        Self::create_card(
            ref world,
            'Kitsune Blessing',
            CardRarity::Common,
            1,
            CardType::Magical,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::AllyStats,
                            value: 1,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );

        // Card 90: Bear Foot
        Self::create_card(
            ref world,
            'Bear Foot',
            CardRarity::Common,
            1,
            CardType::Hunter,
            CardDetails::spell_card(
                SpellCard {
                    effect: CardEffect {
                        modifier: CardModifier {
                            _type: Modifier::AllyStats,
                            value: 1,
                            value_type: ValueType::Fixed,
                            requirement: Option::None,
                        },
                        bonus: Option::None,
                    },
                    extra_effect: Option::None,
                }
            )
        );
    }
}
