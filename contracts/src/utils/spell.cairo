use darkshuffle::models::battle::{Battle, BoardStats, CreatureDetails};
use darkshuffle::models::card::{Modifier, SpellCard};
use darkshuffle::utils::cards::CardUtilsImpl;

#[generate_trait]
impl SpellUtilsImpl of SpellUtilsTrait {
    fn cast_spell(
        spell_card: SpellCard, ref battle: Battle, ref board: Array<CreatureDetails>, board_stats: BoardStats,
    ) {
        let mut creature = CardUtilsImpl::no_creature_card();

        if spell_card.effect.modifier._type.into() != Modifier::None {
            if CardUtilsImpl::_is_requirement_met(
                spell_card.effect.modifier.requirement.into(), spell_card.card_type.into(), board_stats, false,
            ) {
                CardUtilsImpl::apply_card_effect(
                    spell_card.card_type.into(),
                    spell_card.effect,
                    ref creature,
                    ref battle,
                    ref board,
                    board_stats,
                    false,
                );
            }

            if spell_card.extra_effect.modifier._type.into() != Modifier::None {
                if CardUtilsImpl::_is_requirement_met(
                    spell_card.extra_effect.modifier.requirement.into(),
                    spell_card.card_type.into(),
                    board_stats,
                    false,
                ) {
                    CardUtilsImpl::apply_card_effect(
                        spell_card.card_type.into(),
                        spell_card.extra_effect,
                        ref creature,
                        ref battle,
                        ref board,
                        board_stats,
                        false,
                    );
                }
            }
        }
    }
}
