use darkshuffle::models::battle::{Battle, BattleEffects, Creature, Card, Board, BoardStats, CreatureType, RoundStats};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::{
    battle::BattleUtilsImpl,
    board::BoardUtilsImpl,
    cards::CardUtilsImpl
};
use achievement::store::{Store, StoreTrait};
use darkshuffle::utils::tasks::index::{Task, TaskTrait};

#[generate_trait]
impl SummonUtilsImpl of SummonUtilsTrait {
    fn summon_creature(
        card: Card,
        ref battle: Battle,
        ref board: Board,
        ref board_stats: BoardStats,
        ref round_stats: RoundStats,
        game_effects: GameEffects
    ) -> Creature {
        let mut creature: Creature = Creature {
            card_id: card.card_id,
            attack: card.attack,
            health: card.health,
        };
        let creature_type = card.creature_type;

        if round_stats.creatures_played == 0 {
            creature.attack += game_effects.first_attack;
            creature.health += game_effects.first_health;
        }

        if game_effects.play_creature_heal > 0 {
            BattleUtilsImpl::heal_hero(ref battle, game_effects.play_creature_heal);
        }

        creature.attack += game_effects.all_attack;

        if creature_type == CreatureType::Hunter {
            creature.attack += game_effects.hunter_attack;
            creature.health += game_effects.hunter_health;

            creature.attack += battle.battle_effects.next_hunter_attack_bonus;
            creature.health += battle.battle_effects.next_hunter_health_bonus;
            battle.battle_effects.next_hunter_attack_bonus = 0;
            battle.battle_effects.next_hunter_health_bonus = 0;

            if battle.monster.monster_id == 73 {
                battle.monster.attack += 1;
            } else if battle.monster.monster_id == 72 {
                battle.monster.health += 2;
            }

        } else if creature_type == CreatureType::Brute {
            creature.health += game_effects.brute_health;
            creature.attack += game_effects.brute_attack;

            creature.health += battle.battle_effects.next_brute_health_bonus;
            creature.attack += battle.battle_effects.next_brute_attack_bonus;
            battle.battle_effects.next_brute_health_bonus = 0;
            battle.battle_effects.next_brute_attack_bonus = 0;

            if battle.monster.monster_id == 63 {
                battle.monster.attack += 1;
            } else if battle.monster.monster_id == 62 {
                battle.monster.health += 2;
            }
        } else if creature_type == CreatureType::Magical {
            creature.health += game_effects.magical_health;
            creature.attack += game_effects.magical_attack;

            if battle.monster.monster_id == 68 {
                battle.monster.attack += 1;
            } else if battle.monster.monster_id == 67 {
                battle.monster.health += 2;
            }
        }

        if card.card_id == 1 {
            if board_stats.magical_count == 0 {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
            } else {
                BoardUtilsImpl::update_creatures(ref board, CreatureType::Magical, 2, 0);
            }
        }

        else if card.card_id == 4 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::All, 2, 0);
            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::damage_monster(ref battle, 3, creature_type);
            }
        }
        
        else if card.card_id == 7 {
            if board_stats.monster_type == CreatureType::Magical {
                battle.battle_effects.enemy_marks += 3;
            } else {
                battle.battle_effects.enemy_marks += 2;
            }
        }
        
        else if card.card_id == 9 {
            if board_stats.monster_type == CreatureType::Magical {
                BattleUtilsImpl::damage_monster(ref battle, 4, creature_type);
            } else {
                BattleUtilsImpl::damage_monster(ref battle, 2, creature_type);
            }
        }

        else if card.card_id == 12 {
            battle.battle_effects.hero_dmg_reduction += 1;
        }

        else if card.card_id == 14 {
            if board_stats.brute_count > 0 {
                creature.health += 2;
            }
        }

        else if card.card_id == 17 {
            if board_stats.monster_type == CreatureType::Brute {
                creature.attack += 1;
            }

            if board_stats.magical_count > 0 {
                creature.attack += 1;
            }
        }

        else if card.card_id == 18 {
            if board_stats.magical_count > 0 {
                BattleUtilsImpl::increase_hero_energy(ref battle, 1);
                BattleUtilsImpl::heal_hero(ref battle, 2);
            }
        }

        else if card.card_id == 22 {
            if board_stats.hunter_count == 0 {
                creature.attack += 2;
            }
        }

        else if card.card_id == 24 {
            if board_stats.monster_type == CreatureType::Magical {
                battle.battle_effects.enemy_marks += 2;
            } else {
                battle.battle_effects.enemy_marks += 1;
            }
        }

        else if card.card_id == 31 {
            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
                BoardUtilsImpl::update_creatures(ref board, CreatureType::Magical, 0, 1);
            }
        }

        else if card.card_id == 34 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::Magical, 1, 0);

            if board_stats.magical_count >= 2 {
                battle.hero.energy += 1;
            }
        }

        else if card.card_id == 36 {
            battle.battle_effects.enemy_marks += 1;
        }

        else if card.card_id == 39 {
            if board_stats.hunter_count > 0 {
                creature.attack += 1;
            }

            if board_stats.monster_type == CreatureType::Magical {
                BoardUtilsImpl::update_creatures(ref board, CreatureType::Hunter, 1, 0);
            }
        }

        else if card.card_id == 42 {
            if board_stats.brute_count > 0 {
                creature.attack += 1;
            }

            if board_stats.monster_type == CreatureType::Hunter {
                creature.health += 1;
            }
        }

        else if card.card_id == 44 {
            if board_stats.brute_count > 0 {
                creature.attack += 1;
            }

            if board_stats.monster_type == CreatureType::Hunter {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
            }
        }

        else if card.card_id == 47 {
            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
            }
        }

        else if card.card_id == 49 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::Magical, 1, 0);
        }

        else if card.card_id == 51 {
            if board_stats.monster_type == CreatureType::Magical {
                BattleUtilsImpl::damage_monster(ref battle, 1, creature_type);
            }
        }

        else if card.card_id == 54 {
            if board_stats.monster_type == CreatureType::Magical {
                battle.battle_effects.enemy_marks += 1;
            }
        }

        else if card.card_id == 58 {
            if board_stats.brute_count > 0 {
                BattleUtilsImpl::heal_hero(ref battle, 1);
            }
        }

        else if card.card_id == 59 {
            if board_stats.monster_type == CreatureType::Hunter {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
            }
        }
        
        else if card.card_id == 63 {
            if board_stats.monster_type == CreatureType::Brute {
                creature.attack += 2;
            }
        }

        else if card.card_id == 66 {
            if board_stats.monster_type == CreatureType::Magical {
                BattleUtilsImpl::damage_monster(ref battle, 1, creature_type);
            }
        }

        else if card.card_id == 70 {
            if board_stats.hunter_count > 0 {
                creature.attack += 1;
            }
        }

        else if card.card_id == 72 {
            if board_stats.monster_type == CreatureType::Hunter {
                BattleUtilsImpl::damage_monster(ref battle, 1, creature_type);
            }
        }

        else if card.card_id == 74 {
            if board_stats.monster_type == CreatureType::Hunter {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
            }
        }

        if battle.monster.monster_id == 55 {
            if creature.health > creature.attack {
                BattleUtilsImpl::damage_hero(ref battle, game_effects, 2);
            }
        }

        round_stats.creatures_played += 1;
        creature
    }
}