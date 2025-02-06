use darkshuffle::constants::U8_MAX;
use darkshuffle::models::battle::{Battle, BoardStats, Creature, Card, CardType, CreatureType, RoundStats};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::cards::CardUtilsImpl;

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

    fn energy_cost(ref battle: Battle, round_stats: RoundStats, game_effects: GameEffects, card: Card) {
        let mut cost = card.cost;

        if card.card_type == CardType::Creature
            && round_stats.creatures_played == 0
            && game_effects.first_creature_cost > 0 {
            if game_effects.first_creature_cost >= cost {
                return;
            }

            cost -= game_effects.first_creature_cost;
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

    fn damage_monster(ref battle: Battle, amount: u8, creature_type: CreatureType) {
        let mut damage = amount + battle.battle_effects.enemy_marks;

        if damage == 0 {
            return;
        }

        if battle.monster.monster_id == 75 && creature_type == CreatureType::Hunter {
            damage -= 1;
        } else if battle.monster.monster_id == 70 && creature_type == CreatureType::Magical {
            damage -= 1;
        } else if battle.monster.monster_id == 65 && creature_type == CreatureType::Brute {
            damage -= 1;
        }

        if battle.monster.health < damage {
            battle.monster.health = 0;
        } else {
            battle.monster.health -= damage;
        }
    }

    fn damage_creature(ref creature: Creature, board_stats: BoardStats, mut amount: u8, monster_id: u8) {
        let creature_type = CardUtilsImpl::get_card(creature.card_id).creature_type;

        if monster_id == 74 && creature_type == CreatureType::Hunter {
            amount += 1;
        } else if monster_id == 69 && creature_type == CreatureType::Magical {
            amount += 1;
        } else if monster_id == 64 && creature_type == CreatureType::Brute {
            amount += 1;
        }

        let mut reduction = 0;

        if creature.card_id == 27 {
            reduction += 1;

            if board_stats.brute_count > 1 {
                reduction += 1;
            }
        }

        if reduction >= amount {
            return;
        }

        amount -= reduction;

        if creature.health < amount {
            creature.health = 0;
        } else {
            creature.health -= amount;
        }
    }
}
