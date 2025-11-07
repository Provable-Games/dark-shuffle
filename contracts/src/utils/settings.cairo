use darkshuffle::models::config::GameSettings;
use game_components_minigame::extensions::settings::structs::GameSetting;

pub fn generate_settings_array(game_settings: GameSettings) -> Span<GameSetting> {
    array![
        GameSetting { name: "Starting Health", value: format!("{}", game_settings.starting_health) },
        GameSetting { name: "Persistent Health", value: format!("{}", game_settings.persistent_health) },
        GameSetting { name: "Map Level Depth", value: format!("{}", game_settings.map.level_depth) },
        GameSetting { name: "Map Possible Branches", value: format!("{}", game_settings.map.possible_branches) },
        GameSetting { name: "Enemy Attack Min", value: format!("{}", game_settings.map.enemy_attack_min) },
        GameSetting { name: "Enemy Attack Max", value: format!("{}", game_settings.map.enemy_attack_max) },
        GameSetting { name: "Enemy Health Min", value: format!("{}", game_settings.map.enemy_health_min) },
        GameSetting { name: "Enemy Health Max", value: format!("{}", game_settings.map.enemy_health_max) },
        GameSetting { name: "Enemy Attack Scaling", value: format!("{}", game_settings.map.enemy_attack_scaling) },
        GameSetting { name: "Enemy Health Scaling", value: format!("{}", game_settings.map.enemy_health_scaling) },
        GameSetting { name: "Start Energy", value: format!("{}", game_settings.battle.start_energy) },
        GameSetting { name: "Start Hand Size", value: format!("{}", game_settings.battle.start_hand_size) },
        GameSetting { name: "Max Energy", value: format!("{}", game_settings.battle.max_energy) },
        GameSetting { name: "Max Hand Size", value: format!("{}", game_settings.battle.max_hand_size) },
        GameSetting { name: "Draw Amount", value: format!("{}", game_settings.battle.draw_amount) },
        GameSetting { name: "Draft Size", value: format!("{}", game_settings.draft.draft_size) },
        GameSetting { name: "Auto Draft", value: format!("{}", game_settings.draft.auto_draft) },
    ]
        .span()
}
