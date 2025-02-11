use achievement::store::{Store, StoreTrait};
use darkshuffle::models::battle::{Battle, BattleEffects, Creature, Board, BoardStats, RoundStats};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::tasks::index::{Task, TaskTrait};
use darkshuffle::utils::{battle::BattleUtilsImpl, board::BoardUtilsImpl, cards::CardUtilsImpl};
use darkshuffle::models::card::{Card, CardDetails, CardType, CreatureCard};

#[generate_trait]
impl SummonUtilsImpl of SummonUtilsTrait {
    fn summon_creature(
        card: Card,
        creature_details: CreatureCard,
        ref battle: Battle,
        ref board: Board,
        board_stats: BoardStats,
        ref round_stats: RoundStats,
        game_effects: GameEffects
    ) -> Creature {
        let mut creature = Creature { 
            card_id: 1,
            attack: creature_details.attack,
            health: creature_details.health
        };

        if round_stats.creatures_played == 0 {
            creature.attack += game_effects.first_attack;
            creature.health += game_effects.first_health;
        }

        if game_effects.play_creature_heal > 0 {
            BattleUtilsImpl::heal_hero(ref battle, game_effects.play_creature_heal);
        }

        creature.attack += game_effects.all_attack;

        if card.card_type == CardType::Hunter {
            creature.attack += game_effects.hunter_attack;
            creature.health += game_effects.hunter_health;

            creature.attack += battle.battle_effects.next_hunter_attack_bonus;
            creature.health += battle.battle_effects.next_hunter_health_bonus;
            battle.battle_effects.next_hunter_attack_bonus = 0;
            battle.battle_effects.next_hunter_health_bonus = 0;

            if battle.monster.monster_id == 73 {
                battle.monster.attack += 1;
            } else if battle.monster.monster_id == 72 {
                battle.monster.health += 2;
            }
        } else if card.card_type == CardType::Brute {
            creature.health += game_effects.brute_health;
            creature.attack += game_effects.brute_attack;

            creature.health += battle.battle_effects.next_brute_health_bonus;
            creature.attack += battle.battle_effects.next_brute_attack_bonus;
            battle.battle_effects.next_brute_health_bonus = 0;
            battle.battle_effects.next_brute_attack_bonus = 0;

            if battle.monster.monster_id == 63 {
                battle.monster.attack += 1;
            } else if battle.monster.monster_id == 62 {
                battle.monster.health += 2;
            }
        } else if card.card_type == CardType::Magical {
            creature.health += game_effects.magical_health;
            creature.attack += game_effects.magical_attack;

            if battle.monster.monster_id == 68 {
                battle.monster.attack += 1;
            } else if battle.monster.monster_id == 67 {
                battle.monster.health += 2;
            }
        }

        if let Option::Some(play_effect) = creature_details.play_effect {
            if CardUtilsImpl::_is_effect_applicable(play_effect, card.card_type, board_stats) {
                CardUtilsImpl::apply_card_effect(card.card_type, play_effect, ref creature, ref battle, ref board, board_stats);
            }
        }

        if battle.monster.monster_id == 55 {
            if creature.health > creature.attack {
                BattleUtilsImpl::damage_hero(ref battle, game_effects, 2);
            }
        }

        round_stats.creatures_played += 1;
        creature
    }
}
