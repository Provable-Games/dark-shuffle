use darkshuffle::models::battle::{Battle, BattleEffects, Board, BoardStats, Creature, CreatureType};
use darkshuffle::utils::{battle::BattleUtilsImpl, board::BoardUtilsImpl, cards::CardUtilsImpl};

#[generate_trait]
impl DeathUtilsImpl of DeathUtilsTrait {
    fn creature_death(creature: Creature, ref battle: Battle, ref board: Board, board_stats: BoardStats) {
        let creature_type = CardUtilsImpl::get_card(creature.card_id).creature_type;

        if creature.card_id == 3 {
            BattleUtilsImpl::reduce_monster_attack(ref battle, 1);

            if board_stats.monster_type == CreatureType::Brute {
                BoardUtilsImpl::update_creatures(ref board, CreatureType::Magical, 2, 0);
            }
        } else if creature.card_id == 10 {
            if board_stats.monster_type == CreatureType::Magical {
                battle.battle_effects.next_hunter_attack_bonus += 4;
            } else {
                battle.battle_effects.next_hunter_attack_bonus += 2;
            }
        } else if creature.card_id == 11 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::Brute, 2, 0);

            if board_stats.monster_type == CreatureType::Hunter {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 2);
            }
        } else if creature.card_id == 15 {
            if board_stats.monster_type == CreatureType::Hunter {
                battle.battle_effects.next_brute_health_bonus += 5;
            } else {
                battle.battle_effects.next_brute_health_bonus += 3;
            }
        } else if creature.card_id == 16 {
            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
            }

            BoardUtilsImpl::update_creatures(ref board, CreatureType::Magical, 1, 0);
        } else if creature.card_id == 19 {
            BattleUtilsImpl::damage_monster(ref battle, 2, creature_type);

            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
            }
        } else if creature.card_id == 25 {
            battle.battle_effects.next_hunter_attack_bonus += 2;

            if board_stats.monster_type == CreatureType::Magical {
                battle.battle_effects.next_hunter_health_bonus += 2;
            }
        } else if creature.card_id == 26 {
            if board_stats.monster_type == CreatureType::Hunter {
                BattleUtilsImpl::heal_hero(ref battle, 2);
            }
        } else if creature.card_id == 29 {
            battle.battle_effects.next_brute_health_bonus += 2;
        } else if creature.card_id == 30 {
            battle.battle_effects.next_brute_attack_bonus += 1;
        } else if creature.card_id == 33 {
            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::heal_hero(ref battle, 2);
            }

            BoardUtilsImpl::update_creatures(ref board, CreatureType::Magical, 1, 0);
        } else if creature.card_id == 38 {
            battle.battle_effects.next_hunter_attack_bonus += 1;

            if board_stats.monster_type == CreatureType::Magical {
                battle.battle_effects.next_hunter_health_bonus += 1;
            }
        } else if creature.card_id == 41 {
            if board_stats.monster_type == CreatureType::Hunter {
                BoardUtilsImpl::update_creatures(ref board, CreatureType::Brute, 1, 0);
            }
        } else if creature.card_id == 45 {
            if board_stats.monster_type == CreatureType::Hunter {
                if board_stats.brute_count == 1 {
                    BattleUtilsImpl::heal_hero(ref battle, 2);
                } else {
                    BattleUtilsImpl::heal_hero(ref battle, 1);
                }
            }
        } else if creature.card_id == 48 {
            if board_stats.magical_count > 1 {
                BattleUtilsImpl::heal_hero(ref battle, 2);
            }
        } else if creature.card_id == 53 {
            if board_stats.monster_type == CreatureType::Magical {
                battle.battle_effects.next_hunter_attack_bonus += 1;
            }
        } else if creature.card_id == 56 {
            if board_stats.monster_type == CreatureType::Hunter {
                BoardUtilsImpl::update_creatures(ref board, CreatureType::Brute, 1, 0);
            }
        } else if creature.card_id == 60 {
            if board_stats.monster_type == CreatureType::Hunter {
                BattleUtilsImpl::heal_hero(ref battle, 2);
            }
        } else if creature.card_id == 61 {
            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
            }
        } else if creature.card_id == 64 {
            if board_stats.monster_type == CreatureType::Brute {
                BattleUtilsImpl::heal_hero(ref battle, 2);
            }
        } else if creature.card_id == 68 {
            if board_stats.monster_type == CreatureType::Magical {
                battle.battle_effects.next_hunter_attack_bonus += 1;
            }
        } else if creature.card_id == 71 {
            if board_stats.monster_type == CreatureType::Hunter {
                BoardUtilsImpl::update_creatures(ref board, CreatureType::Brute, 1, 0);
            }
        } else if creature.card_id == 73 {
            if board_stats.monster_type == CreatureType::Hunter {
                BattleUtilsImpl::heal_hero(ref battle, 1);
            }
        }
    }
}
