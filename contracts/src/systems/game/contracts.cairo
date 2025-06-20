use darkshuffle::models::game::{GameState};
use starknet::ContractAddress;
use darkshuffle::models::config::CardRarityWeights;

#[starknet::interface]
trait IGameSystems<T> {
    fn start_game(ref self: T, game_id: u64);
    fn pick_card(ref self: T, game_id: u64, option_id: u8);
    fn generate_tree(ref self: T, game_id: u64);
    fn select_node(ref self: T, game_id: u64, node_id: u8);
    fn battle_actions(ref self: T, game_id: u64, battle_id: u16, actions: Span<Span<u8>>);
    fn add_settings(
        ref self: T,
        name: felt252,
        description: ByteArray,
        starting_health: u8,
        start_energy: u8,
        start_hand_size: u8,
        draft_size: u8,
        max_energy: u8,
        max_hand_size: u8,
        draw_amount: u8,
        card_ids: Span<u64>,
        card_rarity_weights: CardRarityWeights,
        auto_draft: bool,
        persistent_health: bool,
        possible_branches: u8,
        level_depth: u8,
        enemy_attack_min: u8,
        enemy_attack_max: u8,
        enemy_health_min: u8,
        enemy_health_max: u8,
        enemy_attack_scaling: u8,
        enemy_health_scaling: u8,
    ) -> u32;
    fn add_random_settings(ref self: T) -> u32;
    fn settings_id(self: @T, game_id: u64) -> u32;
    fn action_count(self: @T, game_id: u64) -> u16;
    fn cards(self: @T, game_id: u64) -> Span<felt252>;
    fn game_state(self: @T, game_id: u64) -> GameState;
    fn health(self: @T, game_id: u64) -> u8;
    fn last_node_id(self: @T, game_id: u64) -> u8;
    fn level(self: @T, game_id: u64) -> u8;
    fn map_depth(self: @T, game_id: u64) -> u8;
    fn monsters_slain(self: @T, game_id: u64) -> u16;
    // fn player_name(self: @T, game_id: u64) -> felt252;
    fn xp(self: @T, game_id: u64) -> u16;
}

#[dojo::contract]
mod game_systems {
    use achievement::store::{Store, StoreTrait};
    use darkshuffle::constants::{DEFAULT_NS, SCORE_ATTRIBUTE, SCORE_MODEL, SETTINGS_MODEL};
    use darkshuffle::models::{
        card::{Card, CardCategory, CreatureCard, SpellCard}, config::{GameSettings, GameSettingsTrait, GameSettingsMetadata, CardRarityWeights},
        draft::{Draft, DraftOwnerTrait}, game::{Game, GameActionEvent, GameOwnerTrait, GameState},
        map::{Map, MonsterNode}, objectives::{ScoreObjective, ScoreObjectiveCount},
    };
    use darkshuffle::utils::tasks::index::{Task, TaskTrait};
    use darkshuffle::systems::battle::contracts::{IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait};
    use darkshuffle::systems::config::contracts::{IConfigSystemsDispatcher, IConfigSystemsDispatcherTrait};

    use darkshuffle::utils::{
        cards::CardUtilsImpl, config::ConfigUtilsImpl, draft::DraftUtilsImpl, map::MapUtilsImpl, random,
        renderer::utils::create_metadata,
    };

    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin_token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait, IERC721Metadata};
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};

    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_tx_info};

    use game_components_minigame::minigame::minigame_component;
    use game_components_minigame::interface::{IMinigameScore, IMinigameDetails, IMinigameSettings, IMinigameObjectives, IMinigameTokenUri};
    use game_components_minigame::models::game_details::{GameDetail};
    use game_components_minigame::models::settings::{GameSetting, GameSettingDetails};
    use game_components_minigame::models::objectives::{GameObjective};

    component!(path: minigame_component, storage: minigame, event: MinigameEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl MinigameImpl = minigame_component::MinigameImpl<ContractState>;
    impl MinigameInternalImpl = minigame_component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        minigame: minigame_component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        MinigameEvent: minigame_component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    fn dojo_init(ref self: ContractState, creator_address: ContractAddress, denshokan_address: ContractAddress) {
        self
            .minigame
            .initializer(
                creator_address,
                'Dark Shuffle',
                "Dark Shuffle is a turn-based, collectible card game. Build your deck, battle monsters, and explore a procedurally generated world.",
                'Provable Games',
                'Provable Games',
                'Digital TCG / Deck Building',
                "https://darkshuffle.io/favicon.svg",
                Option::None,
                Option::None,
                DEFAULT_NS(),
                denshokan_address,
            );
    }

    #[abi(embed_v0)]
    impl GameScoreImpl of IMinigameScore<ContractState> {
        fn score(self: @ContractState, token_id: u64) -> u32 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(token_id);
            game.hero_xp.into()
        }
    }

    #[abi(embed_v0)]
    impl GameDetailsImpl of IMinigameDetails<ContractState> {
        fn token_description(self: @ContractState, token_id: u64) -> ByteArray {
            format!("Test Token Description for token {}", token_id)
        }
        fn game_details(self: @ContractState, token_id: u64) -> Span<GameDetail> {
            array![
                GameDetail {
                    name: "Test Game Detail",
                    value: format!("Test Value for token {}", token_id),
                },
            ].span()
        }
    }

    #[abi(embed_v0)]
    impl SettingsImpl of IMinigameSettings<ContractState> {
        fn setting_exists(self: @ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings.exists()
        }
        fn settings(self: @ContractState, settings_id: u32) -> GameSettingDetails {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            let settings_details: GameSettingsMetadata = world.read_model(settings_id);
            GameSettingDetails {
                name: format!("{}", settings_details.name),
                description: settings_details.description,
                settings: array![
                    GameSetting {
                        name: "Starting Health",
                        value: format!("{}", settings.starting_health),
                    },
                    GameSetting {
                        name: "Persistent Health",
                        value: format!("{}", settings.persistent_health),
                    },
                    GameSetting {
                        name: "Level Depth",
                        value: format!("{}", settings.map.level_depth),
                    },
                    GameSetting {
                        name: "Possible Branches",
                        value: format!("{}", settings.map.possible_branches),
                    },
                    GameSetting {
                        name: "Enemy Attack Min",
                        value: format!("{}", settings.map.enemy_attack_min),
                    },
                    GameSetting {
                        name: "Enemy Attack Max",
                        value: format!("{}", settings.map.enemy_attack_max),
                    },
                    GameSetting {
                        name: "Enemy Health Min",
                        value: format!("{}", settings.map.enemy_health_min),
                    },
                    GameSetting {
                        name: "Enemy Health Max",
                        value: format!("{}", settings.map.enemy_health_max),
                    },
                    GameSetting {
                        name: "Enemy Attack Scaling",
                        value: format!("{}", settings.map.enemy_attack_scaling),
                    },
                    GameSetting {
                        name: "Enemy Health Scaling",
                        value: format!("{}", settings.map.enemy_health_scaling),
                    },
                    GameSetting {
                        name: "Auto Draft",
                        value: format!("{}", settings.draft.auto_draft),
                    },
                    GameSetting {
                        name: "Draft Size",
                        value: format!("{}", settings.draft.draft_size),
                    },    
                ].span(),
            }
        }
    }

    #[abi(embed_v0)]
    impl ObjectivesImpl of IMinigameObjectives<ContractState> {
        fn objective_exists(self: @ContractState, objective_id: u32) -> bool {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let objective_score: ScoreObjective = world.read_model(objective_id);
            objective_score.exists
        }
        fn completed_objective(self: @ContractState, token_id: u64, objective_id: u32) -> bool {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let objective_score: ScoreObjective = world.read_model(objective_id);
            let game: Game = world.read_model(token_id);
            game.hero_xp.into() >= objective_score.score
        }
        fn objectives(self: @ContractState, token_id: u64) -> Span<GameObjective> {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let objective_ids = self.minigame.get_objective_ids(token_id);
            let mut objective_index = 0;
            let mut objectives = array![];
            loop {
                if objective_index == objective_ids.len() {
                    break;
                }
                let objective_id = *objective_ids.at(objective_index);
                let objective_score: ScoreObjective = world.read_model(objective_id);
                objectives.append(GameObjective { name: "Score Target", value: format!("Score Above {}", objective_score.score) });
                objective_index += 1;
            };
            objectives.span()
        }
    }

    #[abi(embed_v0)]
    impl GameSystemsImpl of super::IGameSystems<ContractState> {
        fn start_game(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            self.minigame.pre_action(game_id);
            self.assert_game_not_started(game_id);

            let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, game_id);
            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);
            let action_count = 0;

            let mut game = Game {
                game_id,
                state: GameState::Draft.into(),
                hero_health: game_settings.starting_health,
                hero_xp: 1,
                monsters_slain: 0,
                map_level: 0,
                map_depth: 0,
                last_node_id: 0,
                action_count,
            };

            let card_pool = DraftUtilsImpl::get_weighted_draft_list(world, game_settings);
            if game_settings.draft.auto_draft {
                game.state = GameState::Map.into();
                let draft_list = DraftUtilsImpl::auto_draft(seed, card_pool, game_settings.draft.draft_size);
                world.write_model(@Draft { game_id, options: array![].span(), cards: draft_list });
            } else {
                let options = DraftUtilsImpl::get_draft_options(seed, card_pool);
                world.write_model(@Draft { game_id, options, cards: array![].span() });
            }

            world.write_model(@game);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: action_count,
                    },
                );
            self.minigame.post_action(game_id, false);
        }

        fn pick_card(ref self: ContractState, game_id: u64, option_id: u8) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            self.minigame.pre_action(game_id);

            let mut game: Game = world.read_model(game_id);
            game.assert_draft();

            let mut draft: Draft = world.read_model(game_id);
            draft.add_card(*draft.options.at(option_id.into()));

            let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, game_id);
            let current_draft_size = draft.cards.len();

            if current_draft_size == game_settings.draft.draft_size.into() {
                game.state = GameState::Map.into();
                game.action_count = current_draft_size.try_into().unwrap();
                world.write_model(@game);
            } else {
                let random_hash = random::get_random_hash();
                let seed: u128 = random::get_entropy(random_hash);
                let card_pool = DraftUtilsImpl::get_weighted_draft_list(world, game_settings);
                draft.options = DraftUtilsImpl::get_draft_options(seed, card_pool);
            }

            world.write_model(@draft);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id,
                        tx_hash: starknet::get_tx_info().unbox().transaction_hash,
                        count: current_draft_size.try_into().unwrap(),
                    },
                );
            self.minigame.post_action(game_id, false);
        }

        fn generate_tree(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            self.minigame.pre_action(game_id);

            let mut game: Game = world.read_model(game_id);
            game.assert_generate_tree();

            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);

            game.map_level += 1;
            game.map_depth = 1;
            game.last_node_id = 0;
            game.action_count += 1;

            world.write_model(@Map { game_id, level: game.map_level, seed });

            world.write_model(@game);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: game.action_count,
                    },
                );

            // [Achievement] Complete a map
            if game.map_level > 1 {
                let player_id: felt252 = starknet::get_caller_address().into();
                let task_id: felt252 = Task::Explorer.identifier();
                let time = starknet::get_block_timestamp();
                let store = StoreTrait::new(world);
                store.progress(player_id, task_id, count: 1, time: time);
            }
        }

        fn select_node(ref self: ContractState, game_id: u64, node_id: u8) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            self.minigame.pre_action(game_id);

            let mut game: Game = world.read_model(game_id);
            game.assert_select_node();

            let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, game_id);
            let mut map: Map = world.read_model((game_id, game.map_level));
            assert(MapUtilsImpl::node_available(game, map, node_id, game_settings.map), 'Invalid node');

            game.last_node_id = node_id;

            let monster_node: MonsterNode = MapUtilsImpl::get_monster_node(map, node_id, game_settings.map);
            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);

            MapUtilsImpl::start_battle(ref world, ref game, monster_node, seed);

            game.action_count += 1;

            world.write_model(@game);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: game.action_count,
                    },
                );
            self.minigame.post_action(game_id, false);
        }

        fn battle_actions(ref self: ContractState, game_id: u64, battle_id: u16, actions: Span<Span<u8>>){
            let mut world: WorldStorage = self.world(@DEFAULT_NS());
            self.minigame.pre_action(game_id);
            let (battle_systems_address, _) = world.dns(@"battle_systems").unwrap();
            let battle_systems = IBattleSystemsDispatcher { contract_address: battle_systems_address };
            let hero_is_dead = battle_systems.battle_actions(game_id, battle_id, actions);
            self.minigame.post_action(game_id, hero_is_dead);
        }

        fn add_settings(
            ref self: ContractState,
            name: felt252,
            description: ByteArray,
            starting_health: u8,
            start_energy: u8,
            start_hand_size: u8,
            draft_size: u8,
            max_energy: u8,
            max_hand_size: u8,
            draw_amount: u8,
            card_ids: Span<u64>,
            card_rarity_weights: CardRarityWeights,
            auto_draft: bool,
            persistent_health: bool,
            possible_branches: u8,
            level_depth: u8,
            enemy_attack_min: u8,
            enemy_attack_max: u8,
            enemy_health_min: u8,
            enemy_health_max: u8,
            enemy_attack_scaling: u8,
            enemy_health_scaling: u8,
        ) -> u32 {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());
            let (config_systems_address, _) = world.dns(@"config_systems").unwrap();
            let config_systems = IConfigSystemsDispatcher { contract_address: config_systems_address };
            let (settings_id, settings_json) = config_systems.add_settings(name, description, starting_health, start_energy, start_hand_size, draft_size, max_energy, max_hand_size, draw_amount, card_ids, card_rarity_weights, auto_draft, persistent_health, possible_branches, level_depth, enemy_attack_min, enemy_attack_max, enemy_health_min, enemy_health_max, enemy_attack_scaling, enemy_health_scaling);
            self.minigame.create_settings(settings_id, settings_json);
            settings_id
        }

        fn add_random_settings(ref self: ContractState) -> u32 {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());
            let (config_systems_address, _) = world.dns(@"config_systems").unwrap();
            let config_systems = IConfigSystemsDispatcher { contract_address: config_systems_address };
            let (settings_id, settings_json) = config_systems.add_random_settings();
            self.minigame.create_settings(settings_id, settings_json);
            settings_id
        }

        fn settings_id(self: @ContractState, game_id: u64) -> u32 {
            self.minigame.get_settings_id(game_id)
        }

        // fn player_name(self: @ContractState, game_id: u64) -> felt252 {
        //     let world: WorldStorage = self.world(@DEFAULT_NS());
        //     let token_metadata: TokenMetadata = world.read_model(game_id);
        //     token_metadata.player_name
        // }

        fn health(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_health
        }

        fn game_state(self: @ContractState, game_id: u64) -> GameState {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.state.into()
        }

        fn xp(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_xp
        }

        fn cards(self: @ContractState, game_id: u64) -> Span<felt252> {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let draft: Draft = world.read_model(game_id);
            let mut cards = array![];

            let mut i = 0;
            while i < draft.cards.len() {
                let card: Card = CardUtilsImpl::get_card(world, game_id, *draft.cards.at(i));
                cards.append(card.name);
                i += 1;
            };

            cards.span()
        }

        fn monsters_slain(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.monsters_slain
        }

        fn level(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.map_level
        }

        fn map_depth(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.map_depth
        }

        fn last_node_id(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.last_node_id
        }

        fn action_count(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.action_count
        }
    }

    #[abi(embed_v0)]
    impl MinigameTokenUriImpl of IMinigameTokenUri<ContractState> {
        /// Returns the Uniform Resource Identifier (URI) for the `token_id` token.
        /// If the URI is not set, the return value will be an empty ByteArray.
        ///
        /// Requirements:
        ///
        /// - `token_id` exists.
        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            let token_id_u64 = token_id.try_into().unwrap();

            // let hero_name = self.player_name(token_id_u64);
            let hero_name = 'Test Player';
            let hero_health = self.health(token_id_u64);
            let hero_xp = self.xp(token_id_u64);
            let game_state = self.game_state(token_id_u64);
            let cards = self.cards(token_id_u64);

            create_metadata(token_id_u64, hero_name, hero_health, hero_xp, game_state.into(), cards)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn assert_game_not_started(self: @ContractState, game_id: u64) {
            let game: Game = self.world(@DEFAULT_NS()).read_model(game_id);
            assert!(game.hero_xp == 0, "Dark Shuffle: Game {} has already started", game_id);
        }
    }
}
