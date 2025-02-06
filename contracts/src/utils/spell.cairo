use darkshuffle::models::battle::{Battle, BattleEffects, Board, BoardStats, Card, Creature, CreatureType, RoundStats};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::{battle::BattleUtilsImpl, board::BoardUtilsImpl, cards::CardUtilsImpl};

#[generate_trait]
impl SpellUtilsImpl of SpellUtilsTrait {
    fn cast_spell(card: Card, ref battle: Battle, ref board: Board, ref board_stats: BoardStats) {
        if card.card_id == 76 {
            BattleUtilsImpl::increase_hero_energy(ref battle, 3);
        } else if card.card_id == 77 {
            if board_stats.monster_type == CreatureType::Magical {
                BattleUtilsImpl::damage_monster(ref battle, 8, CreatureType::Spell);
            } else {
                BattleUtilsImpl::damage_monster(ref battle, 4, CreatureType::Spell);
            }
        } else if card.card_id == 78 {
            battle.battle_effects.enemy_marks += 2;
        } else if card.card_id == 79 {
            BattleUtilsImpl::reduce_monster_attack(ref battle, 1);
        } else if card.card_id == 80 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::Brute, 2, 0);
        } else if card.card_id == 81 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::All, 2, 0);
        } else if card.card_id == 82 {
            BattleUtilsImpl::heal_hero(ref battle, board_stats.brute_count);
        } else if card.card_id == 83 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::Hunter, 3, 3);
        } else if card.card_id == 84 {
            BattleUtilsImpl::damage_monster(ref battle, 4, CreatureType::Spell);
            BattleUtilsImpl::heal_hero(ref battle, 4);
        } else if card.card_id == 85 {
            BattleUtilsImpl::damage_monster(ref battle, 4, CreatureType::Spell);
        } else if card.card_id == 86 {
            BattleUtilsImpl::heal_hero(ref battle, 5);
        } else if card.card_id == 87 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::All, 0, 2);
        } else if card.card_id == 88 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::Brute, 1, 1);
        } else if card.card_id == 89 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::Magical, 1, 1);
        } else if card.card_id == 90 {
            BoardUtilsImpl::update_creatures(ref board, CreatureType::Hunter, 1, 1);
        }
    }
}
