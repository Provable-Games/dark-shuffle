use darkshuffle::models::battle::{Battle, CreatureDetails, BoardStats};
use darkshuffle::models::card::{CardDetails};
use darkshuffle::utils::{cards::CardUtilsImpl};

#[generate_trait]
impl DeathUtilsImpl of DeathUtilsTrait {
    fn creature_death(
        ref creature: CreatureDetails, ref battle: Battle, ref board: Array<CreatureDetails>, board_stats: BoardStats
    ) {
        if let CardDetails::creature_card(creature_card) = creature.card.card_details {
            if let Option::Some(death_effect) = creature_card.death_effect {
                if CardUtilsImpl::_is_effect_applicable(death_effect, creature.card.card_type, board_stats) {
                    CardUtilsImpl::apply_card_effect(
                        creature.card.card_type, death_effect, ref creature, ref battle, ref board, board_stats
                    );
                }
            }
        }
    }
}
