use darkshuffle::models::battle::{Battle, BoardStats, CreatureDetails};
use darkshuffle::models::card::{Card, CardDetails, SpellCard};
use darkshuffle::utils::{cards::CardUtilsImpl};

#[generate_trait]
impl SpellUtilsImpl of SpellUtilsTrait {
    fn cast_spell(
        card: Card,
        spell_details: SpellCard,
        ref battle: Battle,
        ref board: Array<CreatureDetails>,
        board_stats: BoardStats,
    ) {
        let mut creature = CardUtilsImpl::no_creature_card();

        if let CardDetails::spell_card(spell_card) = card.card_details {
            if CardUtilsImpl::_is_effect_applicable(spell_card.effect, card.card_type, board_stats) {
                CardUtilsImpl::apply_card_effect(
                    card.card_type, spell_card.effect, ref creature, ref battle, ref board, board_stats,
                );
            }

            if let Option::Some(extra_effect) = spell_card.extra_effect {
                if CardUtilsImpl::_is_effect_applicable(extra_effect, card.card_type, board_stats) {
                    CardUtilsImpl::apply_card_effect(
                        card.card_type, extra_effect, ref creature, ref battle, ref board, board_stats,
                    );
                }
            }
        }
    }
}
