use darkshuffle::models::battle::{Battle, BattleEffects, RoundStats, BoardStats, Creature};
use darkshuffle::models::game::GameEffects;
use darkshuffle::utils::{battle::BattleUtilsImpl, board::BoardUtilsImpl, hand::HandUtilsImpl, random};

#[generate_trait]
impl MonsterUtilsImpl of MonsterUtilsTrait {
    fn monster_ability(
        ref battle: Battle,
        game_effects: GameEffects,
        ref board: Array<Creature>,
        board_stats: BoardStats,
        round_stats: RoundStats,
        seed: u128,
    ) {
        if battle.monster.monster_id == 1 {
            if battle.hand.len() > 0 {
                let random_card = random::get_random_number(seed, battle.hand.len().try_into().unwrap()) - 1;
                HandUtilsImpl::remove_hand_card(ref battle, *battle.hand.at(random_card.into()));
            }
        } else if battle.monster.monster_id == 2 {
            BattleUtilsImpl::damage_hero(ref battle, game_effects, battle.hand.len().try_into().unwrap());
        } else if battle.monster.monster_id == 14 {
            battle.monster.attack += battle.hand.len().try_into().unwrap();
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
}
