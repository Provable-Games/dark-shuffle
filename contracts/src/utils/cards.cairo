use achievement::store::{Store, StoreTrait};
use darkshuffle::models::battle::{Battle, BattleEffects, Creature, BoardStats, RoundStats};
use darkshuffle::models::card::{
    Card, CardRarity, CardDetails, CardType, CreatureCard, SpellCard, CardEffect, CardModifier, Modifier, Requirement,
    ValueType
};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::{battle::BattleUtilsImpl, board::BoardUtilsImpl};

#[generate_trait]
impl CardUtilsImpl of CardUtilsTrait {
    fn apply_card_effect(
        card_type: CardType,
        card_effect: CardEffect,
        ref creature: Creature,
        ref battle: Battle,
        ref board: Array<Creature>,
        board_stats: BoardStats,
    ) {
        let mut modifier_value: u8 = match card_effect.modifier.value_type {
            ValueType::Fixed => card_effect.modifier.value,
            ValueType::PerAlly => card_effect.modifier.value * Self::_ally_count(card_type, board_stats),
        };

        if let Option::Some(bonus) = card_effect.bonus {
            if Self::_requirement_met(bonus.requirement, card_type, board_stats) {
                modifier_value += bonus.value;
            }
        }

        match card_effect.modifier._type {
            Modifier::HeroHealth => BattleUtilsImpl::heal_hero(ref battle, modifier_value),
            Modifier::HeroEnergy => BattleUtilsImpl::increase_hero_energy(ref battle, modifier_value),
            Modifier::HeroDamageReduction => battle.battle_effects.hero_dmg_reduction += modifier_value,
            Modifier::EnemyMarks => battle.battle_effects.enemy_marks += modifier_value,
            Modifier::EnemyAttack => BattleUtilsImpl::reduce_monster_attack(ref battle, modifier_value),
            Modifier::EnemyHealth => BattleUtilsImpl::damage_monster(ref battle, modifier_value, card_type),
            Modifier::NextAllyAttack => BattleUtilsImpl::next_ally_attack(ref battle, card_type, modifier_value),
            Modifier::NextAllyHealth => BattleUtilsImpl::next_ally_health(ref battle, card_type, modifier_value),
            Modifier::AllAttack => BoardUtilsImpl::update_creatures(ref board, Option::None, modifier_value, 0),
            Modifier::AllHealth => BoardUtilsImpl::update_creatures(ref board, Option::None, 0, modifier_value),
            Modifier::AllyAttack => BoardUtilsImpl::update_creatures(
                ref board, Option::Some(card_type), modifier_value, 0
            ),
            Modifier::AllyHealth => BoardUtilsImpl::update_creatures(
                ref board, Option::Some(card_type), 0, modifier_value
            ),
            Modifier::SelfAttack => creature.attack += modifier_value,
            Modifier::SelfHealth => creature.health += modifier_value,
        }
    }

    fn _is_effect_applicable(card_effect: CardEffect, card_type: CardType, board_stats: BoardStats) -> bool {
        if let Option::Some(requirement) = card_effect.modifier.requirement {
            if !Self::_requirement_met(requirement, card_type, board_stats) {
                return false;
            }
        }

        if card_effect.modifier.value_type == ValueType::PerAlly && Self::_ally_count(card_type, board_stats) == 0 {
            return false;
        }

        true
    }

    fn _requirement_met(requirement: Requirement, card_type: CardType, board_stats: BoardStats) -> bool {
        match requirement {
            Requirement::EnemyWeak => Self::_is_enemy_weak(card_type, board_stats.monster_type),
            Requirement::HasAlly => Self::_has_ally(card_type, board_stats),
            Requirement::NoAlly => !Self::_has_ally(card_type, board_stats),
        }
    }

    fn _is_enemy_weak(card_type: CardType, enemy_type: CardType) -> bool {
        (card_type == CardType::Hunter && enemy_type == CardType::Brute)
            || (card_type == CardType::Brute && enemy_type == CardType::Hunter)
            || (card_type == CardType::Magical && enemy_type == CardType::Brute)
    }

    fn _has_ally(card_type: CardType, board_stats: BoardStats) -> bool {
        (card_type == CardType::Hunter && board_stats.hunter_count > 0)
            || (card_type == CardType::Brute && board_stats.brute_count > 0)
            || (card_type == CardType::Magical && board_stats.magical_count > 0)
    }

    fn _ally_count(card_type: CardType, board_stats: BoardStats) -> u8 {
        match card_type {
            CardType::Hunter => board_stats.hunter_count,
            CardType::Brute => board_stats.brute_count,
            CardType::Magical => board_stats.magical_count,
        }
    }


    fn get_card(id: u8) -> Card {
        Card {
            id: 1,
            name: 'Warlock',
            rarity: CardRarity::Legendary,
            cost: 2,
            card_type: CardType::Magical,
            card_details: CardDetails::creature_card(
                CreatureCard {
                    attack: 3,
                    health: 4,
                    play_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::AllAttack,
                                value: 2,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    death_effect: Option::Some(
                        CardEffect {
                            modifier: CardModifier {
                                _type: Modifier::EnemyAttack,
                                value: 1,
                                value_type: ValueType::Fixed,
                                requirement: Option::None,
                            },
                            bonus: Option::None,
                        }
                    ),
                    attack_effect: Option::None,
                }
            ),
        }
    }
}
