use darkshuffle::models::battle::{Battle, CreatureDetails, BoardStats};
use darkshuffle::models::card::{CardDetails};
use darkshuffle::utils::{battle::BattleUtilsImpl, cards::CardUtilsImpl};

#[generate_trait]
impl AttackUtilsImpl of AttackUtilsTrait {
    fn creature_attack(
        ref creature: CreatureDetails, ref battle: Battle, ref board: Array<CreatureDetails>, board_stats: BoardStats
    ) {
        if let CardDetails::creature_card(creature_card) = creature.card.card_details {
            if let Option::Some(attack_effect) = creature_card.attack_effect {
                if CardUtilsImpl::_is_effect_applicable(attack_effect, creature.card.card_type, board_stats) {
                    CardUtilsImpl::apply_card_effect(
                        creature.card.card_type, attack_effect, ref creature, ref battle, ref board, board_stats
                    );
                }
            }
        }

        BattleUtilsImpl::damage_monster(ref battle, creature.attack, creature.card.card_type, board_stats);
        BattleUtilsImpl::damage_creature(ref creature, battle.monster.attack, battle.monster.monster_id);
    }
}
