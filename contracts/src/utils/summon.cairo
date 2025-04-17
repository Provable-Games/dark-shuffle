use achievement::store::{Store, StoreTrait};
use darkshuffle::models::battle::{Battle, BoardStats, Creature, CreatureDetails, RoundStats};
use darkshuffle::models::card::{CardType, CreatureCard, Modifier};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::battle::BattleUtilsImpl;
use darkshuffle::utils::board::BoardUtilsImpl;
use darkshuffle::utils::cards::CardUtilsImpl;
use darkshuffle::utils::tasks::index::{Task, TaskTrait};

#[generate_trait]
impl SummonUtilsImpl of SummonUtilsTrait {
    fn summon_creature(
        card_index: u8,
        creature_card: CreatureCard,
        ref battle: Battle,
        ref board: Array<CreatureDetails>,
        ref board_stats: BoardStats,
        ref round_stats: RoundStats,
        game_effects: GameEffects,
    ) {
        let mut creature = CreatureDetails {
            card_index, attack: creature_card.attack, health: creature_card.health, creature_card,
        };

        if round_stats.creatures_played == 0 {
            BoardUtilsImpl::increase_creature_attack(ref creature, game_effects.first_attack);
            BoardUtilsImpl::increase_creature_health(ref creature, game_effects.first_health);
        }

        if game_effects.play_creature_heal > 0 {
            BattleUtilsImpl::heal_hero(ref battle, game_effects.play_creature_heal);
        }

        BoardUtilsImpl::increase_creature_attack(ref creature, game_effects.all_attack);

        let card_type: CardType = creature_card.card_type.into();
        match card_type {
            CardType::Hunter => {
                BoardUtilsImpl::increase_creature_attack(
                    ref creature, game_effects.hunter_attack + battle.battle_effects.next_hunter_attack_bonus,
                );
                BoardUtilsImpl::increase_creature_health(
                    ref creature, game_effects.hunter_health + battle.battle_effects.next_hunter_health_bonus,
                );

                battle.battle_effects.next_hunter_attack_bonus = 0;
                battle.battle_effects.next_hunter_health_bonus = 0;

                if battle.monster.monster_id == 73 {
                    battle.monster.attack += 1;
                } else if battle.monster.monster_id == 72 {
                    battle.monster.health += 2;
                }
            },
            CardType::Brute => {
                BoardUtilsImpl::increase_creature_attack(
                    ref creature, game_effects.brute_attack + battle.battle_effects.next_brute_attack_bonus,
                );
                BoardUtilsImpl::increase_creature_health(
                    ref creature, game_effects.brute_health + battle.battle_effects.next_brute_health_bonus,
                );

                battle.battle_effects.next_brute_attack_bonus = 0;
                battle.battle_effects.next_brute_health_bonus = 0;

                if battle.monster.monster_id == 63 {
                    battle.monster.attack += 1;
                } else if battle.monster.monster_id == 62 {
                    battle.monster.health += 2;
                }
            },
            CardType::Magical => {
                BoardUtilsImpl::increase_creature_attack(
                    ref creature, game_effects.magical_attack + battle.battle_effects.next_magical_attack_bonus,
                );
                BoardUtilsImpl::increase_creature_health(
                    ref creature, game_effects.magical_health + battle.battle_effects.next_magical_health_bonus,
                );

                battle.battle_effects.next_magical_attack_bonus = 0;
                battle.battle_effects.next_magical_health_bonus = 0;

                if battle.monster.monster_id == 68 {
                    battle.monster.attack += 1;
                } else if battle.monster.monster_id == 67 {
                    battle.monster.health += 2;
                }
            },
            _ => {},
        }

        if creature_card.play_effect.modifier._type.into() != Modifier::None {
            if CardUtilsImpl::_is_requirement_met(
                creature_card.play_effect.modifier.requirement.into(), card_type, board_stats, false,
            ) {
                CardUtilsImpl::apply_card_effect(
                    card_type, creature_card.play_effect, ref creature, ref battle, ref board, board_stats, false,
                );
            }
        }

        if battle.monster.monster_id == 55 {
            if creature.health > creature.attack {
                BattleUtilsImpl::damage_hero(ref battle, game_effects, 2);
            }
        }

        match card_type {
            CardType::Magical => board_stats.magical_count += 1,
            CardType::Brute => board_stats.brute_count += 1,
            CardType::Hunter => board_stats.hunter_count += 1,
            _ => {},
        }

        round_stats.creatures_played += 1;
        board.append(creature);
    }
}
