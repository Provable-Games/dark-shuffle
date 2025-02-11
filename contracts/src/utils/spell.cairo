use darkshuffle::models::battle::{Battle, Board, BoardStats};
use darkshuffle::models::card::{Card, SpellCard, CardDetails};
use darkshuffle::utils::{cards::CardUtilsImpl, board::BoardUtilsImpl};

#[generate_trait]
impl SpellUtilsImpl of SpellUtilsTrait {
    fn cast_spell(card: Card, spell_details: SpellCard, ref battle: Battle, ref board: Board, board_stats: BoardStats) {
        let mut creature = BoardUtilsImpl::no_creature();

        if let CardDetails::spell_card(spell_card) = card.card_details {
            if CardUtilsImpl::_is_effect_applicable(spell_card.play_effect, card.card_type, board_stats) {
                CardUtilsImpl::apply_card_effect(card.card_type, spell_card.play_effect, ref creature, ref battle, ref board, board_stats);
            }
        }
    }
}
