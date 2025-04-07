use darkshuffle::models::battle::{Battle, BoardStats, CreatureDetails};
use darkshuffle::models::card::{Modifier};
use darkshuffle::utils::cards::CardUtilsImpl;

#[generate_trait]
impl DeathUtilsImpl of DeathUtilsTrait {
    fn creature_death(
        ref creature: CreatureDetails, ref battle: Battle, ref board: Array<CreatureDetails>, board_stats: BoardStats,
    ) {
        if creature.creature_card.death_effect.modifier._type.into() != Modifier::None {
            if CardUtilsImpl::_is_requirement_met(
                creature.creature_card.death_effect.modifier.requirement.into(), creature.creature_card.card_type.into(), board_stats, true,
            ) {
                CardUtilsImpl::apply_card_effect(
                    creature.creature_card.card_type.into(), creature.creature_card.death_effect, ref creature, ref battle, ref board, board_stats, true,
                );
            }
        }
    }
}