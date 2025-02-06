use darkshuffle::models::battle::{Battle, BattleEffects, Creature, BoardStats, CreatureType};
use darkshuffle::utils::{battle::BattleUtilsImpl, cards::CardUtilsImpl};

#[generate_trait]
impl AttackUtilsImpl of AttackUtilsTrait {
    fn creature_attack(ref creature: Creature, ref battle: Battle, board_stats: BoardStats) {
        let creature_type = CardUtilsImpl::get_card(creature.card_id).creature_type;
        let mut extra_damage = 0;

        if creature.card_id == 2 {
            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::heal_hero(ref battle, 2);
            }

            creature.health += board_stats.magical_count;
        } else if creature.card_id == 5 {
            if board_stats.magical_count >= 2 {
                extra_damage += 2;
            }
        } else if creature.card_id == 6 {
            if board_stats.monster_type == CreatureType::Magical {
                extra_damage += 5;
            }
        } else if creature.card_id == 8 {
            creature.attack += board_stats.hunter_count;
        } else if creature.card_id == 13 {
            if board_stats.monster_type == CreatureType::Hunter {
                extra_damage += 2;
            }

            if board_stats.brute_count > 1 {
                creature.attack += 1;
            }
        } else if creature.card_id == 20 {
            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
            }
        } else if creature.card_id == 21 {
            if board_stats.monster_type == CreatureType::Magical {
                extra_damage += 1;
            }

            if creature.health > battle.monster.attack {
                creature.health += 1;
            }
        } else if creature.card_id == 23 {
            if board_stats.monster_type == CreatureType::Magical {
                creature.attack += 1;
            }

            if board_stats.hunter_count > 1 {
                extra_damage += 1;
            }
        } else if creature.card_id == 28 {
            if board_stats.monster_type == CreatureType::Hunter {
                creature.health += 2;
            }
        } else if creature.card_id == 32 {
            if board_stats.magical_count > 1 {
                extra_damage += 1;
            }

            if creature.health > battle.monster.attack {
                creature.health += 1;
            }
        } else if creature.card_id == 35 {
            if board_stats.monster_type == CreatureType::Brute {
                extra_damage += 1;
            }

            if board_stats.magical_count == 1 {
                creature.attack += 1;
            }
        } else if creature.card_id == 37 {
            if board_stats.monster_type == CreatureType::Magical {
                creature.attack += 1;
            }

            if board_stats.hunter_count > 0 {
                extra_damage += 1;
            }
        } else if creature.card_id == 40 {
            if board_stats.monster_type == CreatureType::Magical {
                extra_damage += 1;
            }
        } else if creature.card_id == 43 {
            if board_stats.monster_type == CreatureType::Hunter {
                creature.health += 2;
            }
        } else if creature.card_id == 46 {
            if board_stats.monster_type == CreatureType::Brute {
                extra_damage += 1;
            }
        } else if creature.card_id == 50 {
            if board_stats.monster_type == CreatureType::Brute {
                creature.attack += 1;
            }
        } else if creature.card_id == 52 {
            if board_stats.hunter_count == 1 {
                creature.health += 1;
            } else {
                extra_damage += 1;
            }
        } else if creature.card_id == 55 {
            if board_stats.monster_type == CreatureType::Magical {
                extra_damage += 1;
            }
        } else if creature.card_id == 57 {
            if board_stats.monster_type == CreatureType::Hunter {
                extra_damage += 1;
            }
        } else if creature.card_id == 62 {
            if board_stats.magical_count > 1 {
                extra_damage += 1;
            }
        } else if creature.card_id == 65 {
            if board_stats.monster_type == CreatureType::Brute {
                extra_damage += 1;
            }
        } else if creature.card_id == 67 {
            if board_stats.hunter_count > 1 {
                extra_damage += 1;
            }
        } else if creature.card_id == 69 {
            if board_stats.monster_type == CreatureType::Magical {
                extra_damage += 1;
            }
        } else if creature.card_id == 75 {
            if board_stats.brute_count > 1 {
                extra_damage += 1;
            }
        }

        BattleUtilsImpl::damage_monster(ref battle, creature.attack + extra_damage, creature_type);
        BattleUtilsImpl::damage_creature(ref creature, board_stats, battle.monster.attack, battle.monster.monster_id);

        if creature.card_id == 46 {
            creature.attack += 1;
        }
    }
}
