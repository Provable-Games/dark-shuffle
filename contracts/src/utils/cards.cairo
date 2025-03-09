use achievement::store::{Store, StoreTrait};
use darkshuffle::models::battle::{Battle, BattleEffects, BoardStats, Creature, CreatureDetails, RoundStats};
use darkshuffle::models::card::{
    Card, CardDetails, CardEffect, CardModifier, CardRarity, CardType, CreatureCard, Modifier, Requirement, SpellCard,
    ValueType,
};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::{battle::BattleUtilsImpl, board::BoardUtilsImpl, config::ConfigUtilsImpl};
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;

#[generate_trait]
impl CardUtilsImpl of CardUtilsTrait {
    fn apply_card_effect(
        card_type: CardType,
        card_effect: CardEffect,
        ref creature: CreatureDetails,
        ref battle: Battle,
        ref board: Array<CreatureDetails>,
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
            Modifier::EnemyHealth => BattleUtilsImpl::damage_monster(
                ref battle, modifier_value, card_type, board_stats,
            ),
            Modifier::NextAllyAttack => BattleUtilsImpl::next_ally_attack(ref battle, card_type, modifier_value),
            Modifier::NextAllyHealth => BattleUtilsImpl::next_ally_health(ref battle, card_type, modifier_value),
            Modifier::AllAttack => BoardUtilsImpl::update_creatures(ref board, Option::None, modifier_value, 0),
            Modifier::AllHealth => BoardUtilsImpl::update_creatures(ref board, Option::None, 0, modifier_value),
            Modifier::AllyAttack => BoardUtilsImpl::update_creatures(
                ref board, Option::Some(card_type), modifier_value, 0,
            ),
            Modifier::AllyHealth => BoardUtilsImpl::update_creatures(
                ref board, Option::Some(card_type), 0, modifier_value,
            ),
            Modifier::AllyStats => BoardUtilsImpl::update_creatures(
                ref board, Option::Some(card_type), modifier_value, modifier_value,
            ),
            Modifier::SelfAttack => BoardUtilsImpl::increase_creature_attack(ref creature, modifier_value),
            Modifier::SelfHealth => BoardUtilsImpl::increase_creature_health(ref creature, modifier_value),
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

    fn get_card(world: WorldStorage, game_id: u64, card_id: u8) -> Card {
        let card_ids: Span<u64> = ConfigUtilsImpl::get_game_settings(world, game_id).card_ids;
        let card: Card = world.read_model(*card_ids.at(card_id.into()));
        card
    }

    fn no_creature_card() -> CreatureDetails {
        CreatureDetails {
            card: Card {
                id: 0,
                name: 'None',
                rarity: CardRarity::Common,
                cost: 0,
                card_type: CardType::Hunter,
                card_details: CardDetails::creature_card(
                    CreatureCard {
                        attack: 0,
                        health: 0,
                        play_effect: Option::None,
                        death_effect: Option::None,
                        attack_effect: Option::None,
                    },
                ),
            },
            card_id: 0,
            attack: 0,
            health: 0,
        }
    }
}
