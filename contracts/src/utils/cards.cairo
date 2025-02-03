use darkshuffle::models::battle::{Card, CardType, CreatureType, CardTier};

#[generate_trait]
impl CardUtilsImpl of CardUtilsTrait {
    fn get_card(id: u8) -> Card {
        if id == 1 {
            return Card {
                card_id: 1,
                name: 'Warlock',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Magical,
                cost: 2,
                attack: 3,
                health: 4,
            };
        }

        else if id == 2 {
            return Card {
                card_id: 2,
                name: 'Typhon',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Magical,
                cost: 5,
                attack: 6,
                health: 6,
            };
        }
        
        else if id == 3 {
            return Card {
                card_id: 3,
                name: 'Jiangshi',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Magical,
                cost: 3,
                attack: 5,
                health: 4,
            };
        }
        
        else if id == 4 {
            return Card {
                card_id: 4,
                name: 'Anansi',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Magical,
                cost: 4,
                attack: 4,
                health: 5,
            };
        }
        
        else if id == 5 {
            return Card {
                card_id: 5,
                name: 'Basilisk',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Magical,
                cost: 1,
                attack: 3,
                health: 2,
            };
        }

        else if id == 6 {
            return Card {
                card_id: 6,
                name: 'Griffin',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Hunter,
                cost: 5,
                attack: 6,
                health: 4,
            };
        }
        
        else if id == 7 {
            return Card {
                card_id: 7,
                name: 'Manticore',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Hunter,
                cost: 4,
                attack: 4,
                health: 5,
            };
        }
        
        else if id == 8 {
            return Card {
                card_id: 8,
                name: 'Phoenix',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Hunter,
                cost: 1,
                attack: 3,
                health: 2,
            };
        }
        
        else if id == 9 {
            return Card {
                card_id: 9,
                name: 'Dragon',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Hunter,
                cost: 2,
                attack: 4,
                health: 3,
            };
        }

        else if id == 10 {
            return Card {
                card_id: 10,
                name: 'Minotaur',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Hunter,
                cost: 4,
                attack: 5,
                health: 4,
            };
        }
        
        else if id == 11 {
            return Card {
                card_id: 11,
                name: 'Kraken',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Brute,
                cost: 2,
                attack: 3,
                health: 3,
            };
        }
        
        else if id == 12 {
            return Card {
                card_id: 12,
                name: 'Colossus',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Brute,
                cost: 5,
                attack: 5,
                health: 7,
            };
        }
        
        else if id == 13 {
            return Card {
                card_id: 13,
                name: 'Balrog',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Brute,
                cost: 3,
                attack: 4,
                health: 6,
            };
        }

        else if id == 14 {
            return Card {
                card_id: 14,
                name: 'Leviathan',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Brute,
                cost: 1,
                attack: 4,
                health: 3,
            };
        }

        else if id == 15 {
            return Card {
                card_id: 15,
                name: 'Tarrasque',
                card_type: CardType::Creature,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Brute,
                cost: 2,
                attack: 3,
                health: 3,
            };
        }

        else if id == 16 {
            return Card {
                card_id: 16,
                name: 'Gorgon',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Magical,
                cost: 2,
                attack: 3,
                health: 3,
            };
        }

        else if id == 17 {
            return Card {
                card_id: 17,
                name: 'Kitsune',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Magical,
                cost: 4,
                attack: 4,
                health: 3,
            };
        }

        else if id == 18 {
            return Card {
                card_id: 18,
                name: 'Lich',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Magical,
                cost: 4,
                attack: 3,
                health: 4,
            };
        }

        else if id == 19 {
            return Card {
                card_id: 19,
                name: 'Chimera',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Magical,
                cost: 3,
                attack: 3,
                health: 4,
            };
        }

        else if id == 20 {
            return Card {
                card_id: 20,
                name: 'Wendigo',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Magical,
                cost: 2,
                attack: 2,
                health: 3,
            };
        }

        else if id == 21 {
            return Card {
                card_id: 21,
                name: 'Qilin',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Hunter,
                cost: 1,
                attack: 3,
                health: 2,
            };
        }

        else if id == 22 {
            return Card {
                card_id: 22,
                name: 'Ammit',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Hunter,
                cost: 4,
                attack: 5,
                health: 2,
            };
        }

        else if id == 23 {
            return Card {
                card_id: 23,
                name: 'Nue',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Hunter,
                cost: 3,
                attack: 4,
                health: 2,
            };
        }

        else if id == 24 {
            return Card {
                card_id: 24,
                name: 'Skinwalker',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Hunter,
                cost: 5,
                attack: 4,
                health: 3,
            };
        }

        else if id == 25 {
            return Card {
                card_id: 25,
                name: 'Chupacabra',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Hunter,
                cost: 2,
                attack: 2,
                health: 3,
            };
        }

        else if id == 26 {
            return Card {
                card_id: 26,
                name: 'Titan',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Brute,
                cost: 2,
                attack: 2,
                health: 5,
            };
        }

        else if id == 27 {
            return Card {
                card_id: 27,
                name: 'Nephilim',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Brute,
                cost: 5,
                attack: 4,
                health: 4,
            };
        }

        else if id == 28 {
            return Card {
                card_id: 28,
                name: 'Behemoth',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Brute,
                cost: 3,
                attack: 4,
                health: 3,
            };
        }

        else if id == 29 {
            return Card {
                card_id: 29,
                name: 'Hydra',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Brute,
                cost: 1,
                attack: 3,
                health: 2,
            };
        }

        else if id == 30 {
            return Card {
                card_id: 30,
                name: 'Juggernaut',
                card_type: CardType::Creature,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Brute,
                cost: 4,
                attack: 3,
                health: 4,
            };
        }

        else if id == 31 {
            return Card {
                card_id: 31,
                name: 'Rakshasa',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Magical,
                cost: 3,
                attack: 4,
                health: 4,
            };
        }

        else if id == 32 {
            return Card {
                card_id: 32,
                name: 'Werewolf',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Magical,
                cost: 2,
                attack: 3,
                health: 3,
            };
        }

        else if id == 33 {
            return Card {
                card_id: 33,
                name: 'Banshee',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Magical,
                cost: 4,
                attack: 3,
                health: 3,
            };
        }

        else if id == 34 {
            return Card {
                card_id: 34,
                name: 'Draugr',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Magical,
                cost: 1,
                attack: 2,
                health: 2,
            };
        }

        else if id == 35 {
            return Card {
                card_id: 35,
                name: 'Vampire',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Magical,
                cost: 4,
                attack: 4,
                health: 3,
            };
        }

        else if id == 36 {
            return Card {
                card_id: 36,
                name: 'Weretiger',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Hunter,
                cost: 5,
                attack: 6,
                health: 3,
            };
        }

        else if id == 37 {
            return Card {
                card_id: 37,
                name: 'Wyvern',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Hunter,
                cost: 1,
                attack: 3,
                health: 2,
            };
        }

        else if id == 38 {
            return Card {
                card_id: 38,
                name: 'Roc',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Hunter,
                cost: 4,
                attack: 4,
                health: 4,
            };
        }

        else if id == 39 {
            return Card {
                card_id: 39,
                name: 'Harpy',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Hunter,
                cost: 2,
                attack: 3,
                health: 3,
            };
        }

        else if id == 40 {
            return Card {
                card_id: 40,
                name: 'Pegasus',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Hunter,
                cost: 3,
                attack: 4,
                health: 2,
            };
        }

        else if id == 41 {
            return Card {
                card_id: 41,
                name: 'Oni',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Brute,
                cost: 3,
                attack: 3,
                health: 5,
            };
        }

        else if id == 42 {
            return Card {
                card_id: 42,
                name: 'Jotunn',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Brute,
                cost: 2,
                attack: 4,
                health: 3,
            };
        }

        else if id == 43 {
            return Card {
                card_id: 43,
                name: 'Ettin',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Brute,
                cost: 5,
                attack: 5,
                health: 3,
            };
        }

        else if id == 44 {
            return Card {
                card_id: 44,
                name: 'Cyclops',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Brute,
                cost: 4,
                attack: 3,
                health: 4,
            };
        }

        else if id == 45 {
            return Card {
                card_id: 45,
                name: 'Giant',
                card_type: CardType::Creature,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Brute,
                cost: 1,
                attack: 2,
                health: 3,
            };
        }

        else if id == 46 {
            return Card {
                card_id: 46,
                name: 'Goblin',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Magical,
                cost: 2,
                attack: 2,
                health: 3,
            };
        }

        else if id == 47 {
            return Card {
                card_id: 47,
                name: 'Ghoul',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Magical,
                cost: 1,
                attack: 2,
                health: 2,
            };
        }

        else if id == 48 {
            return Card {
                card_id: 48,
                name: 'Wraith',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Magical,
                cost: 3,
                attack: 3,
                health: 2,
            };
        }

        else if id == 49 {
            return Card {
                card_id: 49,
                name: 'Sprite',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Magical,
                cost: 2,
                attack: 2,
                health: 3,
            };
        }

        else if id == 50 {
            return Card {
                card_id: 50,
                name: 'Kappa',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Magical,
                cost: 4,
                attack: 3,
                health: 3,
            };
        }

        else if id == 51 {
            return Card {
                card_id: 51,
                name: 'Hippogriff',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Hunter,
                cost: 1,
                attack: 3,
                health: 1,
            };
        }

        else if id == 52 {
            return Card {
                card_id: 52,
                name: 'Fenrir',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Hunter,
                cost: 2,
                attack: 2,
                health: 2,
            };
        }

        else if id == 53 {
            return Card {
                card_id: 53,
                name: 'Jaguar',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Hunter,
                cost: 3,
                attack: 2,
                health: 3,
            };
        }

        else if id == 54 {
            return Card {
                card_id: 54,
                name: 'Satori',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Hunter,
                cost: 4,
                attack: 4,
                health: 2,
            };
        }

        else if id == 55 {
            return Card {
                card_id: 55,
                name: 'Direwolf',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Hunter,
                cost: 2,
                attack: 2,
                health: 2,
            };
        }

        else if id == 56 {
            return Card {
                card_id: 56,
                name: 'NemeanLion',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Brute,
                cost: 3,
                attack: 2,
                health: 4,
            };
        }

        else if id == 57 {
            return Card {
                card_id: 57,
                name: 'Berserker',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Brute,
                cost: 2,
                attack: 3,
                health: 2,
            };
        }

        else if id == 58 {
            return Card {
                card_id: 58,
                name: 'Yeti',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Brute,
                cost: 1,
                attack: 3,
                health: 2,
            };
        }

        else if id == 59 {
            return Card {
                card_id: 59,
                name: 'Golem',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Brute,
                cost: 4,
                attack: 4,
                health: 2,
            };
        }

        else if id == 60 {
            return Card {
                card_id: 60,
                name: 'Ent',
                card_type: CardType::Creature,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Brute,
                cost: 2,
                attack: 2,
                health: 3,
            };
        }

        else if id == 61 {
            return Card {
                card_id: 61,
                name: 'Fairy',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Magical,
                cost: 4,
                attack: 3,
                health: 3,
            };
        }

        else if id == 62 {
            return Card {
                card_id: 62,
                name: 'Leprechaun',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Magical,
                cost: 2,
                attack: 2,
                health: 2,
            };
        }

        else if id == 63 {
            return Card {
                card_id: 63,
                name: 'Kelpie',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Magical,
                cost: 1,
                attack: 1,
                health: 1,
            };
        }

        else if id == 64 {
            return Card {
                card_id: 64,
                name: 'Pixie',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Magical,
                cost: 3,
                attack: 2,
                health: 3,
            };
        }

        else if id == 65 {
            return Card {
                card_id: 65,
                name: 'Gnome',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Magical,
                cost: 5,
                attack: 4,
                health: 3,
            };
        }

        else if id == 66 {
            return Card {
                card_id: 66,
                name: 'Bear',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Hunter,
                cost: 4,
                attack: 3,
                health: 2,
            };
        }

        else if id == 67 {
            return Card {
                card_id: 67,
                name: 'Wolf',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Hunter,
                cost: 2,
                attack: 2,
                health: 2,
            };
        }

        else if id == 68 {
            return Card {
                card_id: 68,
                name: 'Mantis',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Hunter,
                cost: 1,
                attack: 1,
                health: 1,
            };
        }

        else if id == 69 {
            return Card {
                card_id: 69,
                name: 'Spider',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Hunter,
                cost: 3,
                attack: 3,
                health: 2,
            };
        }

        else if id == 70 {
            return Card {
                card_id: 70,
                name: 'Rat',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Hunter,
                cost: 5,
                attack: 4,
                health: 4,
            };
        }

        else if id == 71 {
            return Card {
                card_id: 71,
                name: 'Troll',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Brute,
                cost: 4,
                attack: 3,
                health: 4,
            };
        }

        else if id == 72 {
            return Card {
                card_id: 72,
                name: 'Bigfoot',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Brute,
                cost: 2,
                attack: 3,
                health: 2,
            };
        }

        else if id == 73 {
            return Card {
                card_id: 73,
                name: 'Ogre',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Brute,
                cost: 1,
                attack: 1,
                health: 2,
            };
        }

        else if id == 74 {
            return Card {
                card_id: 74,
                name: 'Orc',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Brute,
                cost: 3,
                attack: 2,
                health: 3,
            };
        }

        else if id == 75 {
            return Card {
                card_id: 75,
                name: 'Skeleton',
                card_type: CardType::Creature,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Brute,
                cost: 5,
                attack: 4,
                health: 3,
            };
        }

        else if id == 76 {
            return Card {
                card_id: 76,
                name: 'Warlocks Pact',
                card_type: CardType::Spell,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Spell,
                cost: 1,
                attack: 0,
                health: 0,
            };
        }

        else if id == 77 {
            return Card {
                card_id: 77,
                name: 'Dragons Breath',
                card_type: CardType::Spell,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Spell,
                cost: 1,
                attack: 0,
                health: 0,
            };
        }

        else if id == 78 {
            return Card {
                card_id: 78,
                name: 'Jiangshis Curse',
                card_type: CardType::Spell,
                card_tier: CardTier::T1,
                creature_type: CreatureType::Spell,
                cost: 2,
                attack: 0,
                health: 0,
            };
        }

        else if id == 79 {
            return Card {
                card_id: 79,
                name: 'Gorgons Gaze',
                card_type: CardType::Spell,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Spell,
                cost: 2,
                attack: 0,
                health: 0,
            };
        }

        else if id == 80 {
            return Card {
                card_id: 80,
                name: 'Titans Call',
                card_type: CardType::Spell,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Spell,
                cost: 1,
                attack: 0,
                health: 0,
            };
        }

        else if id == 81 {
            return Card {
                card_id: 81,
                name: 'Wendigos Frenzy',
                card_type: CardType::Spell,
                card_tier: CardTier::T2,
                creature_type: CreatureType::Spell,
                cost: 2,
                attack: 0,
                health: 0,
            };
        }

        else if id == 82 {
            return Card {
                card_id: 82,
                name: 'Giant Shoulders',
                card_type: CardType::Spell,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Spell,
                cost: 2,
                attack: 0,
                health: 0,
            };
        }

        else if id == 83 {
            return Card {
                card_id: 83,
                name: 'Werewolves Howl',
                card_type: CardType::Spell,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Spell,
                cost: 4,
                attack: 0,
                health: 0,
            };
        }

        else if id == 84 {
            return Card {
                card_id: 84,
                name: 'Vampires Bite',
                card_type: CardType::Spell,
                card_tier: CardTier::T3,
                creature_type: CreatureType::Spell,
                cost: 5,
                attack: 0,
                health: 0,
            };
        }

        else if id == 85 {
            return Card {
                card_id: 85,
                name: 'Wraiths Shadow',
                card_type: CardType::Spell,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Spell,
                cost: 1,
                attack: 0,
                health: 0,
            };
        }

        else if id == 86 {
            return Card {
                card_id: 86,
                name: 'Sprites Favor',
                card_type: CardType::Spell,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Spell,
                cost: 5,
                attack: 0,
                health: 0,
            };
        }

        else if id == 87 {
            return Card {
                card_id: 87,
                name: 'Kappas Gift',
                card_type: CardType::Spell,
                card_tier: CardTier::T4,
                creature_type: CreatureType::Spell,
                cost: 2,
                attack: 0,
                health: 0,
            };
        }

        else if id == 88 {
            return Card {
                card_id: 88,
                name: 'Ogres Strength',
                card_type: CardType::Spell,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Spell,
                cost: 1,
                attack: 0,
                health: 0,
            };
        }

        else if id == 89 {
            return Card {
                card_id: 89,
                name: 'Pixies Blessing',
                card_type: CardType::Spell,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Spell,
                cost: 1,
                attack: 0,
                health: 0,
            };
        }

        else if id == 90 {
            return Card {
                card_id: 90,
                name: 'Bears Foot',
                card_type: CardType::Spell,
                card_tier: CardTier::T5,
                creature_type: CreatureType::Spell,
                cost: 1,
                attack: 0,
                health: 0,
            };
        }

        Card {
            card_id: 0,
            name: 'None',
            card_type: CardType::Creature,
            card_tier: CardTier::T1,
            creature_type: CreatureType::None,
            cost: 0,
            attack: 0,
            health: 0,
        }
    }
}
