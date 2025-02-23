use darkshuffle::models::battle::{Creature, Battle, BoardStats, RoundStats};
use darkshuffle::models::card::CardType;
use darkshuffle::utils::{attack::AttackUtilsImpl, death::DeathUtilsImpl, cards::CardUtilsImpl};

#[generate_trait]
impl BoardUtilsImpl of BoardUtilsTrait {
    fn no_creature() -> Creature {
        Creature { card_id: 0, attack: 0, health: 0 }
    }

    fn get_board(board: Span<Creature>) -> Array<Creature> {
        let mut new_board = array![];

        let mut i = 0;
        while i < board.len() {
            new_board.append(*board.at(i));
            i += 1;
        };

        new_board
    }

    fn attack_monster(
        ref battle: Battle, ref board: Array<Creature>, board_stats: BoardStats, ref round_stats: RoundStats
    ) {
        let mut i = 0;

        while i < board.len() {
            let mut creature = board.pop_front().unwrap();
            AttackUtilsImpl::creature_attack(ref creature, ref battle, ref board, board_stats);
            board.append(creature);
            i += 1;
        };

        round_stats.creature_attack_count += board.len().try_into().unwrap();
    }

    fn get_board_stats(ref board: Array<Creature>, monster_id: u8) -> BoardStats {
        let mut stats: BoardStats = BoardStats {
            magical_count: 0,
            brute_count: 0,
            hunter_count: 0,
            monster_type: CardUtilsImpl::get_card(monster_id).card_type,
        };

        let mut i = 0;
        while i < board.len() {
            match CardUtilsImpl::get_card(*board.at(i).card_id).card_type {
                CardType::Magical => stats.magical_count += 1,
                CardType::Brute => stats.brute_count += 1,
                CardType::Hunter => stats.hunter_count += 1,
            };
            i += 1;
        };

        stats
    }

    fn update_creatures(ref board: Array<Creature>, _type: Option<CardType>, attack: u8, health: u8) {
        let mut i = 0;
        while i < board.len() {
            if _type == Option::None || _type == Option::Some(CardUtilsImpl::get_card(*board.at(i).card_id).card_type) {
                let mut creature = board.pop_front().unwrap();
                creature.attack += attack;
                creature.health += health;
                board.append(creature);
            }
            i += 1;
        };
    }

    fn remove_dead_creatures(ref battle: Battle, ref board: Array<Creature>, board_stats: BoardStats) {
        let mut new_board = array![];

        let mut i = 0;
        while i < board.len() {
            let mut creature = board.pop_front().unwrap();
            if creature.health == 0 {
                DeathUtilsImpl::creature_death(ref creature, ref battle, ref board, board_stats);
            } else {
                new_board.append(creature);
            }
            i += 1;
        };

        board = new_board;
    }

    fn get_strongest_creature(ref board: Array<Creature>) -> Creature {
        let mut strongest_creature = Self::no_creature();

        if board.len() == 0 {
            return strongest_creature;
        }

        let mut i = 0;
        while i < board.len() {
            if *board.at(i).attack > strongest_creature.attack {
                strongest_creature = *board.at(i);
            }
            i += 1;
        };

        strongest_creature
    }
}
