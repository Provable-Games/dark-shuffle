use darkshuffle::models::battle::{Battle, BattleEffects, BattleResources, CreatureDetails, RoundStats};
use darkshuffle::models::card::{CardType, CreatureCard};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::battle::BattleUtilsImpl;
use darkshuffle::utils::board::BoardUtilsImpl;
use darkshuffle::utils::hand::HandUtilsImpl;
use darkshuffle::utils::random;

#[generate_trait]
impl MonsterUtilsImpl of MonsterUtilsTrait {
    fn monster_ability(
        ref battle: Battle,
        ref battle_resources: BattleResources,
        game_effects: GameEffects,
        ref board: Array<CreatureDetails>,
        round_stats: RoundStats,
        seed: u128,
    ) {
        if battle.monster.monster_id == 1 {
            if battle_resources.hand.len() > 0 {
                let random_card = random::get_random_number(seed, battle_resources.hand.len().try_into().unwrap()) - 1;
                HandUtilsImpl::remove_hand_card(ref battle_resources, *battle_resources.hand.at(random_card.into()));
            }
        } else if battle.monster.monster_id == 2 {
            BattleUtilsImpl::damage_hero(ref battle, game_effects, battle_resources.hand.len().try_into().unwrap());
        } else if battle.monster.monster_id == 14 {
            battle.monster.attack += battle_resources.hand.len().try_into().unwrap();
        } else if battle.monster.monster_id == 15 {
            battle.monster.attack += round_stats.creature_attack_count;
        } else if battle.monster.monster_id == 30 && battle.monster.health >= round_stats.monster_start_health {
            BattleUtilsImpl::damage_hero(ref battle, game_effects, 3);
        } else if battle.monster.monster_id == 57 {
            let mut strongest_creature = BoardUtilsImpl::get_strongest_creature(ref board);

            if strongest_creature.attack > battle.monster.attack {
                battle.monster.health += 2;
            }
        } else if battle.monster.monster_id == 58 {
            let strongest_creature = BoardUtilsImpl::get_strongest_creature(ref board);

            if strongest_creature.attack > battle.monster.attack {
                battle.monster.attack += 1;
            }
        } else if battle.monster.monster_id == 59 {
            if battle.monster.health >= round_stats.monster_start_health {
                battle.monster.attack += 2;
            }
        }
    }

    fn get_monster_type(monster_id: u8) -> CardType {
        let remainder = monster_id % 15;

        if remainder >= 1 && remainder <= 5 {
            CardType::Magical
        } else if remainder >= 6 && remainder <= 10 {
            CardType::Hunter
        } else if remainder == 0 || (remainder >= 11 && remainder <= 14) {
            CardType::Brute
        } else {
            CardType::Brute
        }
    }
}
