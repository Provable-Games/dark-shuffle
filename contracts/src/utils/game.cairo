use darkshuffle::models::battle::{Battle};
use darkshuffle::models::config::{GameSettings};
use darkshuffle::models::game::{Game, GameEffects, GameState};
use darkshuffle::models::map::{Map, MonsterNode};

use darkshuffle::utils::{achievements::AchievementsUtilsImpl, battle::BattleUtilsImpl, map::MapUtilsImpl};
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[generate_trait]
impl GameUtilsImpl of GameUtilsTrait {
    fn is_battle_over(battle: Battle) -> bool {
        if battle.monster.health > 0 && battle.hero.health > 0 {
            return false;
        }

        true
    }

    fn end_battle(
        ref world: WorldStorage, ref battle: Battle, ref game_effects: GameEffects, game_settings: GameSettings
    ) {
        let mut game: Game = world.read_model((battle.game_id));
        let map: Map = world.read_model((game.game_id, game.map_level));
        let monster_node: MonsterNode = MapUtilsImpl::get_monster_node(map, game.last_node_id);

        game.action_count += battle.round.into();

        if battle.hero.health == 0 {
            Self::battle_lost(ref world, ref battle, ref game, monster_node);
        } else if battle.monster.health == 0 {
            Self::battle_won(ref world, ref battle, ref game_effects, ref game, monster_node, game_settings);
        }

        world.write_model(@battle);
    }

    fn battle_won(
        ref world: WorldStorage,
        ref battle: Battle,
        ref game_effects: GameEffects,
        ref game: Game,
        monster_node: MonsterNode,
        game_settings: GameSettings,
    ) {
        // [Achievement] Defeat enemy
        AchievementsUtilsImpl::defeat_enemy(ref world, battle, monster_node.monster_id);
        // [Achievement] Survivor
        if battle.hero.health == 1 {
            AchievementsUtilsImpl::survivor(ref world);
        }
        // [Achievement] Heroic
        if battle.hero.health > game.hero_health {
            AchievementsUtilsImpl::heroic(ref world);
        }

        Self::add_monster_reward(ref game_effects, ref battle, monster_node.monster_id);

        game.monsters_slain += 1;
        game.state = GameState::Map.into();
        game.map_depth += 1;
        game.hero_xp += monster_node.health.into();
        if game_settings.persistent_health {
            game.hero_health = battle.hero.health;
        }

        world.write_model(@game);
        world.write_model(@game_effects);
    }

    fn battle_lost(ref world: WorldStorage, ref battle: Battle, ref game: Game, monster_node: MonsterNode) {
        game.state = GameState::Over.into();

        game.hero_health = 0;

        if monster_node.health > battle.monster.health {
            game.hero_xp += (monster_node.health - battle.monster.health).into();
        }

        world.write_model(@game);
    }

    fn add_monster_reward(ref game_effects: GameEffects, ref battle: Battle, monster_id: u8) {
        if monster_id == 1 {
            game_effects.card_draw += 1;
        } else if monster_id == 2 {
            game_effects.hero_card_heal = true;
        } else if monster_id == 3 {
            game_effects.hunter_health += 2;
            game_effects.hunter_attack += 2;
        } else if monster_id == 15 {
            game_effects.play_creature_heal += 1;
        } else if monster_id == 20 {
            game_effects.all_attack += 1;
        } else if monster_id == 30 {
            game_effects.first_creature_cost += 1;
        } else if monster_id == 55 {
            game_effects.first_attack += 1;
        } else if monster_id == 57 {
            game_effects.first_health += 2;
        } else if monster_id == 58 {
            game_effects.start_bonus_energy += 1;
        } else if monster_id == 59 {
            game_effects.start_bonus_energy += 1;
        } else if monster_id == 62 || monster_id == 64 {
            game_effects.hunter_health += 1;
        } else if monster_id == 60 || monster_id == 63 || monster_id == 65 {
            game_effects.hunter_attack += 1;
        } else if monster_id == 67 || monster_id == 69 {
            game_effects.brute_health += 1;
        } else if monster_id == 68 || monster_id == 70 {
            game_effects.brute_attack += 1;
        } else if monster_id == 72 || monster_id == 74 {
            game_effects.magical_health += 1;
        } else if monster_id == 73 || monster_id == 75 {
            game_effects.magical_attack += 1;
        } // Heal rewards
        else if monster_id > 3 && monster_id < 30 {
            BattleUtilsImpl::heal_hero(ref battle, 20);
        } else if monster_id >= 31 && monster_id <= 45 {
            BattleUtilsImpl::heal_hero(ref battle, 15);
        } else if monster_id >= 46 && monster_id <= 56 {
            BattleUtilsImpl::heal_hero(ref battle, 10);
        } else if monster_id == 61 || monster_id == 66 || monster_id == 71 {
            BattleUtilsImpl::heal_hero(ref battle, 5);
        }
    }
}
