use darkshuffle::models::battle::{Creature, Board, Battle, BattleEffects, CreatureType, BoardStats, RoundStats};
use darkshuffle::utils::{attack::AttackUtilsImpl, death::DeathUtilsImpl, cards::CardUtilsImpl};

#[generate_trait]
impl BoardUtilsImpl of BoardUtilsTrait {
    fn no_creature() -> Creature {
        Creature { card_id: 0, attack: 0, health: 0, }
    }

    fn add_creature_to_board(creature: Creature, ref board: Board, ref board_stats: BoardStats) {
        if board.creature1.card_id == 0 {
            board.creature1 = creature;
        } else if board.creature2.card_id == 0 {
            board.creature2 = creature;
        } else if board.creature3.card_id == 0 {
            board.creature3 = creature;
        } else if board.creature4.card_id == 0 {
            board.creature4 = creature;
        } else if board.creature5.card_id == 0 {
            board.creature5 = creature;
        } else if board.creature6.card_id == 0 {
            board.creature6 = creature;
        } else {
            panic(array!['Board is full']);
        }

        let creature_type = CardUtilsImpl::get_card(creature.card_id).creature_type;
        if creature_type == CreatureType::Magical {
            board_stats.magical_count += 1;
        } else if creature_type == CreatureType::Brute {
            board_stats.brute_count += 1;
        } else if creature_type == CreatureType::Hunter {
            board_stats.hunter_count += 1;
        }
    }

    fn attack_monster(ref battle: Battle, ref board: Board, board_stats: BoardStats, ref round_stats: RoundStats) {
        if board.creature1.card_id != 0 {
            AttackUtilsImpl::creature_attack(ref board.creature1, ref battle, board_stats);
            round_stats.creature_attack_count += 1;
        }

        if board.creature2.card_id != 0 {
            AttackUtilsImpl::creature_attack(ref board.creature2, ref battle, board_stats);
            round_stats.creature_attack_count += 1;
        }

        if board.creature3.card_id != 0 {
            AttackUtilsImpl::creature_attack(ref board.creature3, ref battle, board_stats);
            round_stats.creature_attack_count += 1;
        }

        if board.creature4.card_id != 0 {
            AttackUtilsImpl::creature_attack(ref board.creature4, ref battle, board_stats);
            round_stats.creature_attack_count += 1;
        }

        if board.creature5.card_id != 0 {
            AttackUtilsImpl::creature_attack(ref board.creature5, ref battle, board_stats);
            round_stats.creature_attack_count += 1;
        }

        if board.creature6.card_id != 0 {
            AttackUtilsImpl::creature_attack(ref board.creature6, ref battle, board_stats);
            round_stats.creature_attack_count += 1;
        }
    }

    fn get_board_stats(board: Board, monster_id: u8) -> BoardStats {
        let mut stats: BoardStats = BoardStats {
            magical_count: 0,
            brute_count: 0,
            hunter_count: 0,
            monster_type: CardUtilsImpl::get_card(monster_id).creature_type,
        };

        if board.creature1.card_id != 0 {
            let creature_type = CardUtilsImpl::get_card(board.creature1.card_id).creature_type;
            if creature_type == CreatureType::Magical {
                stats.magical_count += 1;
            } else if creature_type == CreatureType::Brute {
                stats.brute_count += 1;
            } else if creature_type == CreatureType::Hunter {
                stats.hunter_count += 1;
            }
        }

        if board.creature2.card_id != 0 {
            let creature_type = CardUtilsImpl::get_card(board.creature2.card_id).creature_type;
            if creature_type == CreatureType::Magical {
                stats.magical_count += 1;
            } else if creature_type == CreatureType::Brute {
                stats.brute_count += 1;
            } else if creature_type == CreatureType::Hunter {
                stats.hunter_count += 1;
            }
        }

        if board.creature3.card_id != 0 {
            let creature_type = CardUtilsImpl::get_card(board.creature3.card_id).creature_type;
            if creature_type == CreatureType::Magical {
                stats.magical_count += 1;
            } else if creature_type == CreatureType::Brute {
                stats.brute_count += 1;
            } else if creature_type == CreatureType::Hunter {
                stats.hunter_count += 1;
            }
        }

        if board.creature4.card_id != 0 {
            let creature_type = CardUtilsImpl::get_card(board.creature4.card_id).creature_type;
            if creature_type == CreatureType::Magical {
                stats.magical_count += 1;
            } else if creature_type == CreatureType::Brute {
                stats.brute_count += 1;
            } else if creature_type == CreatureType::Hunter {
                stats.hunter_count += 1;
            }
        }

        if board.creature5.card_id != 0 {
            let creature_type = CardUtilsImpl::get_card(board.creature5.card_id).creature_type;
            if creature_type == CreatureType::Magical {
                stats.magical_count += 1;
            } else if creature_type == CreatureType::Brute {
                stats.brute_count += 1;
            } else if creature_type == CreatureType::Hunter {
                stats.hunter_count += 1;
            }
        }

        if board.creature6.card_id != 0 {
            let creature_type = CardUtilsImpl::get_card(board.creature6.card_id).creature_type;
            if creature_type == CreatureType::Magical {
                stats.magical_count += 1;
            } else if creature_type == CreatureType::Brute {
                stats.brute_count += 1;
            } else if creature_type == CreatureType::Hunter {
                stats.hunter_count += 1;
            }
        }

        stats
    }

    fn update_creatures(ref board: Board, creature_type: CreatureType, attack: u8, health: u8) {
        if board.creature1.card_id != 0 {
            if creature_type == CreatureType::All
                || creature_type == CardUtilsImpl::get_card(board.creature1.card_id).creature_type {
                board.creature1.attack += attack;
                board.creature1.health += health;
            }
        }

        if board.creature2.card_id != 0 {
            if creature_type == CreatureType::All
                || creature_type == CardUtilsImpl::get_card(board.creature2.card_id).creature_type {
                board.creature2.attack += attack;
                board.creature2.health += health;
            }
        }

        if board.creature3.card_id != 0 {
            if creature_type == CreatureType::All
                || creature_type == CardUtilsImpl::get_card(board.creature3.card_id).creature_type {
                board.creature3.attack += attack;
                board.creature3.health += health;
            }
        }

        if board.creature4.card_id != 0 {
            if creature_type == CreatureType::All
                || creature_type == CardUtilsImpl::get_card(board.creature4.card_id).creature_type {
                board.creature4.attack += attack;
                board.creature4.health += health;
            }
        }

        if board.creature5.card_id != 0 {
            if creature_type == CreatureType::All
                || creature_type == CardUtilsImpl::get_card(board.creature5.card_id).creature_type {
                board.creature5.attack += attack;
                board.creature5.health += health;
            }
        }

        if board.creature6.card_id != 0 {
            if creature_type == CreatureType::All
                || creature_type == CardUtilsImpl::get_card(board.creature6.card_id).creature_type {
                board.creature6.attack += attack;
                board.creature6.health += health;
            }
        }
    }

    fn clean_board(ref battle: Battle, ref board: Board, board_stats: BoardStats) {
        if board.creature1.card_id != 0 && board.creature1.health == 0 {
            DeathUtilsImpl::creature_death(board.creature1, ref battle, ref board, board_stats);
            board.creature1 = Self::no_creature();
        }

        if board.creature2.card_id != 0 && board.creature2.health == 0 {
            DeathUtilsImpl::creature_death(board.creature2, ref battle, ref board, board_stats);
            board.creature2 = Self::no_creature();
        }

        if board.creature3.card_id != 0 && board.creature3.health == 0 {
            DeathUtilsImpl::creature_death(board.creature3, ref battle, ref board, board_stats);
            board.creature3 = Self::no_creature();
        }

        if board.creature4.card_id != 0 && board.creature4.health == 0 {
            DeathUtilsImpl::creature_death(board.creature4, ref battle, ref board, board_stats);
            board.creature4 = Self::no_creature();
        }

        if board.creature5.card_id != 0 && board.creature5.health == 0 {
            DeathUtilsImpl::creature_death(board.creature5, ref battle, ref board, board_stats);
            board.creature5 = Self::no_creature();
        }

        if board.creature6.card_id != 0 && board.creature6.health == 0 {
            DeathUtilsImpl::creature_death(board.creature6, ref battle, ref board, board_stats);
            board.creature6 = Self::no_creature();
        }
    }

    fn get_strongest_creature(board: Board) -> Creature {
        let mut strongest_creature = board.creature1;

        if board.creature2.attack > strongest_creature.attack {
            strongest_creature = board.creature2;
        }

        if board.creature3.attack > strongest_creature.attack {
            strongest_creature = board.creature3;
        }

        if board.creature4.attack > strongest_creature.attack {
            strongest_creature = board.creature4;
        }

        if board.creature5.attack > strongest_creature.attack {
            strongest_creature = board.creature5;
        }

        if board.creature6.attack > strongest_creature.attack {
            strongest_creature = board.creature6;
        }

        strongest_creature
    }
}
