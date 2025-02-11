use darkshuffle::models::battle::{Battle, BattleEffects, Creature, Board, BoardStats};
use darkshuffle::models::card::{Card, CardDetails, CreatureCard};
use darkshuffle::utils::{battle::BattleUtilsImpl, cards::CardUtilsImpl};

#[generate_trait]
impl AttackUtilsImpl of AttackUtilsTrait {
    fn creature_attack(ref creature: Creature, ref battle: Battle, ref board: Board, board_stats: BoardStats) {
        let card = CardUtilsImpl::get_card(creature.card_id);

        if let CardDetails::creature_card(creature_card) = card.card_details {
            if let Option::Some(attack_effect) = creature_card.attack_effect {
                if CardUtilsImpl::_is_effect_applicable(attack_effect, card.card_type, board_stats) {
                    CardUtilsImpl::apply_card_effect(card.card_type, attack_effect, ref creature, ref battle, ref board, board_stats);
                }
            }
        }

        BattleUtilsImpl::damage_monster(ref battle, creature.attack, card.card_type);
        BattleUtilsImpl::damage_creature(ref creature, board_stats, battle.monster.attack, battle.monster.monster_id);
    }
}
