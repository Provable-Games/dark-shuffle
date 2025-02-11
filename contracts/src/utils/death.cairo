use darkshuffle::models::battle::{Battle, Creature, Board, BoardStats};
use darkshuffle::models::card::{Card, CardDetails};
use darkshuffle::utils::{cards::CardUtilsImpl};

#[generate_trait]
impl DeathUtilsImpl of DeathUtilsTrait {
    fn creature_death(ref creature: Creature, ref battle: Battle, ref board: Board, board_stats: BoardStats) {
        let card = CardUtilsImpl::get_card(creature.card_id);

        if let CardDetails::creature_card(creature_card) = card.card_details {
            if let Option::Some(death_effect) = creature_card.death_effect {
                if CardUtilsImpl::_is_effect_applicable(death_effect, card.card_type, board_stats) {
                    CardUtilsImpl::apply_card_effect(card.card_type, death_effect, ref creature, ref battle, ref board, board_stats);
                }
            }
        }
    }
}
