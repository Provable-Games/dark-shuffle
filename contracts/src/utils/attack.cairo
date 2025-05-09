use darkshuffle::models::battle::{Battle, BoardStats, CreatureDetails};
use darkshuffle::models::card::{CardType, Modifier};
use darkshuffle::utils::battle::BattleUtilsImpl;
use darkshuffle::utils::cards::CardUtilsImpl;

#[generate_trait]
impl AttackUtilsImpl of AttackUtilsTrait {
    fn creature_attack(
        ref creature: CreatureDetails, ref battle: Battle, ref board: Array<CreatureDetails>, board_stats: BoardStats,
    ) {
        let card_type: CardType = creature.creature_card.card_type.into();
        if creature.creature_card.attack_effect.modifier._type.into() != Modifier::None {
            if CardUtilsImpl::_is_requirement_met(
                creature.creature_card.attack_effect.modifier.requirement.into(), card_type, board_stats, true,
            ) {
                CardUtilsImpl::apply_card_effect(
                    card_type,
                    creature.creature_card.attack_effect,
                    ref creature,
                    ref battle,
                    ref board,
                    board_stats,
                    true,
                );
            }
        }

        BattleUtilsImpl::damage_monster(ref battle, creature.attack, card_type, board_stats);
        BattleUtilsImpl::damage_creature(ref creature, battle.monster.attack, battle.monster.monster_id);
    }
}
