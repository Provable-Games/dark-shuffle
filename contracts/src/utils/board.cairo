use core::num::traits::OverflowingAdd;
use darkshuffle::constants::U8_MAX;
use darkshuffle::models::battle::{Battle, BoardStats, Creature, CreatureDetails, RoundStats};
use darkshuffle::models::card::{Card, CardType, CreatureCard};
use darkshuffle::utils::attack::AttackUtilsImpl;
use darkshuffle::utils::cards::CardUtilsImpl;
use darkshuffle::utils::death::DeathUtilsImpl;
use darkshuffle::utils::monsters::MonsterUtilsImpl;
use dojo::world::WorldStorage;

#[generate_trait]
pub impl BoardUtilsImpl of BoardUtilsTrait {
    fn get_packed_board(ref board: Array<CreatureDetails>) -> Span<Creature> {
        let mut packed_board = array![];

        let mut i = 0;
        while i < board.len() {
            packed_board
                .append(
                    Creature {
                        card_index: *board.at(i).card_index, attack: *board.at(i).attack, health: *board.at(i).health,
                    },
                );
            i += 1;
        };

        packed_board.span()
    }

    fn unpack_board(world: WorldStorage, game_id: u64, board: Span<Creature>) -> Array<CreatureDetails> {
        let mut unpacked_board = array![];

        let mut i = 0;
        while i < board.len() {
            let card: Card = CardUtilsImpl::get_card(world, game_id, *board.at(i).card_index);
            let creature_card: CreatureCard = CardUtilsImpl::get_creature_card(world, card.id);
            unpacked_board
                .append(
                    CreatureDetails {
                        card_index: *board.at(i).card_index,
                        attack: *board.at(i).attack,
                        health: *board.at(i).health,
                        creature_card: creature_card,
                    },
                );
            i += 1;
        };

        unpacked_board
    }

    fn attack_monster(
        ref battle: Battle, ref board: Array<CreatureDetails>, board_stats: BoardStats, ref round_stats: RoundStats,
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
            let creature: CreatureDetails = *board.at(i);
            let card_type: CardType = creature.creature_card.card_type.into();
            match card_type {
                CardType::Magical => stats.magical_count += 1,
                CardType::Brute => stats.brute_count += 1,
                CardType::Hunter => stats.hunter_count += 1,
                _ => {},
            }
            i += 1;
        };

        stats
    }

    fn update_creatures(ref board: Array<CreatureDetails>, _type: Option<CardType>, attack: u8, health: u8) {
        let mut i = 0;
        while i < board.len() {
            let mut creature = board.pop_front().unwrap();
            if _type == Option::None || _type == Option::Some(creature.creature_card.card_type.into()) {
                Self::increase_creature_attack(ref creature, attack);
                Self::increase_creature_health(ref creature, health);
            }
            board.append(creature);
            i += 1;
        };
    }

    fn remove_dead_creatures(ref battle: Battle, ref board: Array<CreatureDetails>, board_stats: BoardStats) {
        let mut i = 0;
        while i < board.len() {
            let mut creature = board.pop_front().unwrap();
            if creature.health == 0 {
                DeathUtilsImpl::creature_death(ref creature, ref battle, ref board, board_stats);
            } else {
                board.append(creature);
            }
            i += 1;
        };
    }

    fn get_strongest_creature(ref board: Array<CreatureDetails>) -> CreatureDetails {
        let mut strongest_creature = CardUtilsImpl::no_creature_card();

        if board.len() == 0 {
            return strongest_creature;
        }

        let mut i = 0;
        while i < board.len() {
            if *board.at(i).attack > strongest_creature.attack {
                strongest_creature.attack = *board.at(i).attack;
            }
            i += 1;
        };

        strongest_creature
    }

    fn increase_creature_attack(ref creature: CreatureDetails, amount: u8) {
        let (result, overflow) = OverflowingAdd::overflowing_add(creature.attack, amount);
        creature.attack = if overflow {
            U8_MAX
        } else {
            result
        };
    }

    fn increase_creature_health(ref creature: CreatureDetails, amount: u8) {
        let (result, overflow) = OverflowingAdd::overflowing_add(creature.health, amount);
        creature.health = if overflow {
            U8_MAX
        } else {
            result
        };
    }
}
