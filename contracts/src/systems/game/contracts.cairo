use darkshuffle::models::config::CardRarityWeights;
use darkshuffle::models::game::{GameState};
use starknet::ContractAddress;

#[starknet::interface]
trait IGameSystems<T> {
    fn start_game(ref self: T, game_id: u64);
    fn pick_card(ref self: T, game_id: u64, option_id: u8);
    fn generate_tree(ref self: T, game_id: u64);
    fn select_node(ref self: T, game_id: u64, node_id: u8);
    fn battle_actions(ref self: T, game_id: u64, battle_id: u16, actions: Span<Span<u8>>);
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
        card::{Card, CardCategory, CreatureCard, SpellCard},
        config::{CardRarityWeights, GameSettings, GameSettingsMetadata, GameSettingsTrait},
        draft::{Draft, DraftOwnerTrait}, game::{Game, GameActionEvent, GameOwnerTrait, GameState},
        map::{Map, MonsterNode}, objectives::{ScoreObjective, ScoreObjectiveCount},
    };
    use darkshuffle::systems::battle::contracts::{IBattleSystemsDispatcher, IBattleSystemsDispatcherTrait};
    use darkshuffle::systems::config::contracts::{IConfigSystemsDispatcher, IConfigSystemsDispatcherTrait};
    use darkshuffle::utils::tasks::index::{Task, TaskTrait};

    use darkshuffle::utils::{
        cards::CardUtilsImpl, config::ConfigUtilsImpl, draft::DraftUtilsImpl, map::MapUtilsImpl, random,
        renderer::utils::create_metadata,
    };

    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use game_components_minigame::interface::{
        IMinigameDetails, IMinigameTokenData, IMinigameTokenUri,
    };
    use game_components_minigame::libs::assert_token_ownership;
    use game_components_minigame_objectives::interface::{IMinigameObjectives};
    use game_components_minigame_settings::interface::{IMinigameSettings};

    use game_components_minigame::minigame::minigame_component;
    use game_components_minigame_objectives::objectives::objectives_component;
    use game_components_minigame::structs::{GameDetail};
    use game_components_minigame_objectives::structs::{GameObjective};
    use game_components_minigame_settings::structs::{GameSetting, GameSettingDetails};

    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin_token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait, IERC721Metadata};
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};

    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_tx_info};

    component!(path: minigame_component, storage: minigame, event: MinigameEvent);
    component!(path: objectives_component, storage: objectives, event: ObjectivesEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl MinigameImpl = minigame_component::MinigameImpl<ContractState>;
    impl MinigameInternalImpl = minigame_component::InternalImpl<ContractState>;
    impl MinigameObjectivesInternalImpl = objectives_component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        minigame: minigame_component::Storage,
        #[substorage(v0)]
        objectives: objectives_component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        MinigameEvent: minigame_component::Event,
        #[flat]
        ObjectivesEvent: objectives_component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    fn dojo_init(ref self: ContractState, creator_address: ContractAddress, denshokan_address: ContractAddress) {
        let mut world: WorldStorage = self.world(@DEFAULT_NS());
        let (settings_systems_address, _) = world.dns(@"config_systems").unwrap();

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
                Option::None, // color
                Option::None, // client_url
                Option::None, // renderer address
                Option::Some(settings_systems_address), // settings_address
                Option::None, // objectives_address
                denshokan_address,
            );
    }

    #[abi(embed_v0)]
    impl GameTokenDataImpl of IMinigameTokenData<ContractState> {
        fn score(self: @ContractState, token_id: u64) -> u32 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(token_id);
            game.hero_xp.into()
        }

        fn game_over(self: @ContractState, token_id: u64) -> bool {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(token_id);
            game.hero_health == 0
        }
    }

    #[abi(embed_v0)]
    impl GameDetailsImpl of IMinigameDetails<ContractState> {
        fn token_description(self: @ContractState, token_id: u64) -> ByteArray {
            format!("Test Token Description for token {}", token_id)
        }
        fn game_details(self: @ContractState, token_id: u64) -> Span<GameDetail> {
            array![GameDetail { name: "Test Game Detail", value: format!("Test Value for token {}", token_id) }].span()
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
            let objective_ids = self.objectives.get_objective_ids(token_id, self.minigame_token_address());
            let mut objective_index = 0;
            let mut objectives = array![];
            loop {
                if objective_index == objective_ids.len() {
                    break;
                }
                let objective_id = *objective_ids.at(objective_index);
                let objective_score: ScoreObjective = world.read_model(objective_id);
                objectives
                    .append(
                        GameObjective { name: "Score Target", value: format!("Score Above {}", objective_score.score) },
                    );
                objective_index += 1;
            };
            objectives.span()
        }
    }

    #[abi(embed_v0)]
    impl GameSystemsImpl of super::IGameSystems<ContractState> {
        fn start_game(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            assert_token_ownership(self.minigame.minigame_token_address(), game_id);

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
            self.minigame.post_action(game_id);
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
            self.minigame.post_action(game_id);
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
            self.minigame.post_action(game_id);
        }

        fn battle_actions(ref self: ContractState, game_id: u64, battle_id: u16, actions: Span<Span<u8>>) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());
            self.minigame.pre_action(game_id);
            let (battle_systems_address, _) = world.dns(@"battle_systems").unwrap();
            let battle_systems = IBattleSystemsDispatcher { contract_address: battle_systems_address };
            battle_systems.battle_actions(game_id, battle_id, actions);
            self.minigame.post_action(game_id);
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
