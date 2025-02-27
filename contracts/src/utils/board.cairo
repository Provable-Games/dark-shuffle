use darkshuffle::models::battle::{Creature, Battle, BoardStats, RoundStats, CreatureDetails};
use darkshuffle::models::card::{Card, CardType};
use darkshuffle::utils::{attack::AttackUtilsImpl, death::DeathUtilsImpl, cards::CardUtilsImpl, monsters::MonsterUtilsImpl};
use dojo::world::WorldStorage;

#[generate_trait]
impl BoardUtilsImpl of BoardUtilsTrait {
    fn get_packed_board(ref board: Array<CreatureDetails>) -> Span<Creature> {
        let mut packed_board = array![];

        let mut i = 0;
        while i < board.len() {
            packed_board
                .append(
                    Creature { card_id: *board.at(i).card_id, attack: *board.at(i).attack, health: *board.at(i).health }
                );
            i += 1;
        };

        packed_board.span()
    }

    fn unpack_board(world: WorldStorage, game_id: u64, board: Span<Creature>) -> Array<CreatureDetails> {
        let mut unpacked_board = array![];

        let mut i = 0;
        while i < board.len() {
            let card: Card = CardUtilsImpl::get_card(world, game_id, *board.at(i).card_id);
            unpacked_board
                .append(
                    CreatureDetails {
                        card: card,
                        card_id: *board.at(i).card_id,
                        attack: *board.at(i).attack,
                        health: *board.at(i).health
                    }
                );
            i += 1;
        };

        unpacked_board
    }

    fn attack_monster(
        ref battle: Battle, ref board: Array<CreatureDetails>, board_stats: BoardStats, ref round_stats: RoundStats
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

    fn get_board_stats(ref board: Array<CreatureDetails>, monster_id: u8) -> BoardStats {
        let monster_type = MonsterUtilsImpl::get_monster_type(monster_id);
        let mut stats: BoardStats = BoardStats { magical_count: 0, brute_count: 0, hunter_count: 0, monster_type };

        let mut i = 0;
        while i < board.len() {
            match board.at(i).card.card_type {
                CardType::Magical => stats.magical_count += 1,
                CardType::Brute => stats.brute_count += 1,
                CardType::Hunter => stats.hunter_count += 1,
            };
            i += 1;
        };

        stats
    }

    fn update_creatures(ref board: Array<CreatureDetails>, _type: Option<CardType>, attack: u8, health: u8) {
        let mut i = 0;
        while i < board.len() {
            if _type == Option::None || _type == Option::Some(*board.at(i).card.card_type) {
                let mut creature = board.pop_front().unwrap();
                creature.attack += attack;
                creature.health += health;
                board.append(creature);
            }
            i += 1;
        };
    }

    fn remove_dead_creatures(ref battle: Battle, ref board: Array<CreatureDetails>, board_stats: BoardStats) {
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

    fn get_strongest_creature(ref board: Array<CreatureDetails>) -> CreatureDetails {
        let mut strongest_creature = CardUtilsImpl::no_creature_card();

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
