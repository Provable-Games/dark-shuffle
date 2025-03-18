use darkshuffle::constants::LAST_NODE_DEPTH;
use darkshuffle::models::battle::{Battle, BattleEffects, BattleResources, Hero, Monster};
use darkshuffle::models::config::{GameSettings, CardRarityWeights, MapSettings, BattleSettings, DraftSettings};
use darkshuffle::models::draft::Draft;
use darkshuffle::models::game::{Game, GameState};
use darkshuffle::models::map::Map;
use darkshuffle::utils::testing::mock::gameTokenMock::{IGameTokenMockDispatcher, IGameTokenMockDispatcherTrait};
use darkshuffle::utils::testing::systems::deploy_game_token_mock;
use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use starknet::{ContractAddress, contract_address_const, get_caller_address};
use tournaments::components::game::game_component;
use tournaments::components::interfaces::{
    IGameDetails, IGameToken, IGameTokenDispatcher, IGameTokenDispatcherTrait, ISettings,
};

fn mint_game_token(
    world: WorldStorage,
    token_address: ContractAddress,
    player_name: felt252,
    settings_id: u32,
    available_at: Option<u64>,
    expires_at: Option<u64>,
    to: ContractAddress,
) -> u64 {
    let game_systems_dispatcher = IGameTokenDispatcher { contract_address: token_address };
    game_systems_dispatcher.mint(player_name, settings_id, available_at, expires_at, to)
}

fn create_game(ref world: WorldStorage, game_id: u64, state: GameState) {
    world
        .write_model_test(
            @Game {
                game_id,
                state: state.into(),
                hero_health: 100,
                hero_xp: 1,
                monsters_slain: 0,
                map_level: 0,
                map_depth: LAST_NODE_DEPTH,
                last_node_id: 0,
                action_count: 0,
            },
        );
}

fn create_draft(ref world: WorldStorage, game_id: u64, options: Span<u8>, cards: Span<u8>) {
    world.write_model_test(@Draft { game_id, options, cards });
}

fn create_map(ref world: WorldStorage, game_id: u64, level: u8, seed: u128) {
    world.write_model_test(@Map { game_id, level, seed });
}

fn create_battle(
    ref world: WorldStorage,
    game_id: u64,
    round: u8,
    hero_health: u8,
    hero_energy: u8,
    monster_id: u8,
    monster_attack: u8,
    monster_health: u8,
) -> u16 {
    let battle_id = 1;

    world
        .write_model_test(
            @Battle {
                battle_id,
                game_id,
                round,
                hero: Hero { health: hero_health, energy: hero_energy },
                monster: Monster { monster_id, attack: monster_attack, health: monster_health },
                battle_effects: BattleEffects {
                    enemy_marks: 0,
                    hero_dmg_reduction: 0,
                    next_hunter_attack_bonus: 0,
                    next_hunter_health_bonus: 0,
                    next_brute_attack_bonus: 0,
                    next_brute_health_bonus: 0,
                    next_magical_attack_bonus: 0,
                    next_magical_health_bonus: 0,
                },
            },
        );

    battle_id
}

fn create_battle_resources(ref world: WorldStorage, game_id: u64, hand: Span<u8>, deck: Span<u8>) {
    world.write_model_test(@BattleResources { battle_id: 1, game_id, hand, deck, board: array![].span() });
}

fn create_custom_settings(
    ref world: WorldStorage,
    starting_health: u8,
    start_energy: u8,
    start_hand_size: u8,
    draft_size: u8,
    max_energy: u8,
    max_hand_size: u8,
    draw_amount: u8,
    persistent_health: bool,
    auto_draft: bool,
    card_ids: Span<u64>,
    card_rarity_weights: CardRarityWeights,
    possible_branches: u8,
    enemy_starting_attack: u8,
    enemy_starting_health: u8,
) -> u32 {
    let settings_id = 99;

    world
        .write_model_test(
            @GameSettings {
                settings_id,
                starting_health,
                persistent_health,
                map: MapSettings {
                    possible_branches,
                    enemy_starting_attack,
                    enemy_starting_health,
                },
                battle: BattleSettings {
                    start_energy,
                    start_hand_size,
                    max_energy,
                    max_hand_size,
                    draw_amount,
                },
                draft: DraftSettings {
                    draft_size,
                    card_ids,
                    card_rarity_weights,
                    auto_draft,
                },
            },
        );

    settings_id
}