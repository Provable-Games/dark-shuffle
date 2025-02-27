use darkshuffle::constants::U8_MAX;
use darkshuffle::models::battle::{Battle, BoardStats, CreatureDetails, RoundStats};
use darkshuffle::models::card::{Card, CardDetails, CardType};
use darkshuffle::models::game::GameEffects;

#[generate_trait]
impl BattleUtilsImpl of BattleUtilsTrait {
    fn reduce_monster_attack(ref battle: Battle, amount: u8) {
        if battle.monster.attack < amount {
            battle.monster.attack = 1;
        } else {
            battle.monster.attack -= amount;
        }

        if battle.monster.attack == 0 {
            battle.monster.attack = 1;
        }
    }

    fn deduct_energy_cost(ref battle: Battle, round_stats: RoundStats, game_effects: GameEffects, card: Card) {
        let mut cost = card.cost;

        if let CardDetails::creature_card(_) = card.card_details {
            if round_stats.creatures_played == 0 && game_effects.first_creature_cost > 0 {
                if game_effects.first_creature_cost >= cost {
                    return;
                }

                cost -= game_effects.first_creature_cost;
            }
        }

        assert(battle.hero.energy >= cost, 'Not enough energy');
        battle.hero.energy -= cost;
    }

    fn heal_hero(ref battle: Battle, amount: u8) {
        if battle.hero.health + amount >= U8_MAX {
            battle.hero.health = U8_MAX;
        } else {
            battle.hero.health += amount;
        }
    }

    fn increase_hero_energy(ref battle: Battle, amount: u8) {
        battle.hero.energy += amount;
    }

    fn damage_hero(ref battle: Battle, game_effects: GameEffects, amount: u8) {
        if amount <= battle.battle_effects.hero_dmg_reduction {
            return;
        }

        let mut damage = amount - battle.battle_effects.hero_dmg_reduction;

        if damage <= game_effects.hero_dmg_reduction {
            return;
        }

        damage -= game_effects.hero_dmg_reduction;

        if battle.hero.health < damage {
            battle.hero.health = 0;
        } else {
            battle.hero.health -= damage;
        }
    }

    fn damage_monster(ref battle: Battle, amount: u8, card_type: CardType, board_stats: BoardStats) {
        let mut damage = amount + battle.battle_effects.enemy_marks;

        if damage == 0 {
            return;
        }

        if battle.monster.monster_id == 75 && card_type == CardType::Hunter {
            damage -= 1;
        } else if battle.monster.monster_id == 70 && card_type == CardType::Magical {
            damage -= 1;
        } else if battle.monster.monster_id == 65 && card_type == CardType::Brute {
            damage -= 1;
        }

        if battle.monster.health < damage {
            battle.monster.health = 0;
        } else {
            battle.monster.health -= damage;
        }
    }

    fn damage_creature(ref creature: CreatureDetails, mut amount: u8, monster_id: u8) {
        if monster_id == 74 && creature.card.card_type == CardType::Hunter {
            amount += 1;
        } else if monster_id == 69 && creature.card.card_type == CardType::Magical {
            amount += 1;
        } else if monster_id == 64 && creature.card.card_type == CardType::Brute {
            amount += 1;
        }

        if creature.health < amount {
            creature.health = 0;
        } else {
            creature.health -= amount;
        }
    }

    fn next_ally_attack(ref battle: Battle, card_type: CardType, amount: u8) {
        match card_type {
            CardType::Hunter => battle.battle_effects.next_hunter_attack_bonus += amount,
            CardType::Brute => battle.battle_effects.next_brute_attack_bonus += amount,
            CardType::Magical => battle.battle_effects.next_magical_attack_bonus += amount,
        };
    }

    fn next_ally_health(ref battle: Battle, card_type: CardType, amount: u8) {
        match card_type {
            CardType::Hunter => battle.battle_effects.next_hunter_health_bonus += amount,
            CardType::Brute => battle.battle_effects.next_brute_health_bonus += amount,
            CardType::Magical => battle.battle_effects.next_magical_health_bonus += amount,
        };
    }
}
