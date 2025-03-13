use achievement::store::{Store, StoreTrait};
use darkshuffle::models::battle::{Battle, BattleEffects, BoardStats, Creature, CreatureDetails, RoundStats};
use darkshuffle::models::card::{
    Card, CardEffect, CardModifier, CardType, CreatureCard, Modifier, Requirement, SpellCard,
    ValueType, EffectBonus
};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::battle::BattleUtilsImpl;
use darkshuffle::utils::board::BoardUtilsImpl;
use darkshuffle::utils::config::ConfigUtilsImpl;
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
        on_board: bool,
    ) {
        let mut value_type: ValueType = card_effect.modifier.value_type.into();
        let mut modifier_value: u8 = match value_type {
            ValueType::Fixed => card_effect.modifier.value,
            ValueType::PerAlly => card_effect.modifier.value * Self::_ally_count(card_type, board_stats),
            _ => 0,
        };

        if card_effect.bonus.value != 0 {
            if Self::_is_requirement_met(card_effect.bonus.requirement.into(), card_type, board_stats, on_board) {
                match value_type {
                    ValueType::Fixed => modifier_value += card_effect.bonus.value,
                    ValueType::PerAlly => modifier_value += card_effect.bonus.value * Self::_ally_count(card_type, board_stats),
                    _ => {},
                }
            }
        }

        let modifier_type: Modifier = card_effect.modifier._type.into();
        match modifier_type {
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
            _ => {},
        }
    }

    fn _is_requirement_met(
        requirement: Requirement, card_type: CardType, board_stats: BoardStats, on_board: bool,
    ) -> bool {
        let ally_count: u8 = if on_board {
            1
        } else {
            0
        };

        match requirement {
            Requirement::None => true,
            Requirement::EnemyWeak => Self::_is_enemy_weak(card_type, board_stats.monster_type),
            Requirement::HasAlly => Self::_ally_count(card_type, board_stats) > ally_count,
            Requirement::NoAlly => Self::_ally_count(card_type, board_stats) == ally_count,
        }
    }

    fn _is_enemy_weak(card_type: CardType, enemy_type: CardType) -> bool {
        (card_type == CardType::Hunter && enemy_type == CardType::Magical)
            || (card_type == CardType::Brute && enemy_type == CardType::Hunter)
            || (card_type == CardType::Magical && enemy_type == CardType::Brute)
    }

    fn _ally_count(card_type: CardType, board_stats: BoardStats) -> u8 {
        match card_type {
            CardType::Hunter => board_stats.hunter_count,
            CardType::Brute => board_stats.brute_count,
            CardType::Magical => board_stats.magical_count,
            _ => 0,
        }
    }

    fn get_card(world: WorldStorage, game_id: u64, card_index: u8) -> Card {
        let card_ids: Span<u64> = ConfigUtilsImpl::get_game_settings(world, game_id).card_ids;
        let card: Card = world.read_model(*card_ids.at(card_index.into()));
        card
    }

    fn get_creature_card(world: WorldStorage, card_id: u64) -> CreatureCard {
        let creature_card: CreatureCard = world.read_model(card_id);
        creature_card
    }

    fn get_spell_card(world: WorldStorage, card_id: u64) -> SpellCard {
        let spell_card: SpellCard = world.read_model(card_id);
        spell_card
    }

    fn no_creature_card() -> CreatureDetails {
        CreatureDetails {
            card_index: 0,
            attack: 0,
            health: 0,
            creature_card: CreatureCard {
                id: 0,
                attack: 0,
                health: 0,
                card_type: 0,
                play_effect: CardEffect {
                    modifier: CardModifier { _type: 0, value_type: 0, value: 0, requirement: 0 },
                    bonus: EffectBonus { value: 0, requirement: 0 },
                },
                death_effect: CardEffect {
                    modifier: CardModifier { _type: 0, value_type: 0, value: 0, requirement: 0 },
                    bonus: EffectBonus { value: 0, requirement: 0 },
                },
                attack_effect: CardEffect {
                    modifier: CardModifier { _type: 0, value_type: 0, value: 0, requirement: 0 },
                    bonus: EffectBonus { value: 0, requirement: 0 },
                },
            },
        }
    }
}
