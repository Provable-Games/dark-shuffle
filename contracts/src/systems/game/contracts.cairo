use darkshuffle::models::game::{GameState};

#[starknet::interface]
pub trait IGameSystems<T> {
    fn start_game(ref self: T, game_id: u64);
    fn pick_card(ref self: T, game_id: u64, option_id: u8);
    fn generate_tree(ref self: T, game_id: u64);
    fn select_node(ref self: T, game_id: u64, node_id: u8);

    fn action_count(self: @T, game_id: u64) -> u16;
    fn cards(self: @T, game_id: u64) -> Span<felt252>;
    fn game_state(self: @T, game_id: u64) -> GameState;
    fn health(self: @T, game_id: u64) -> u8;
    fn last_node_id(self: @T, game_id: u64) -> u8;
    fn level(self: @T, game_id: u64) -> u8;
    fn map_depth(self: @T, game_id: u64) -> u8;
    fn monsters_slain(self: @T, game_id: u64) -> u16;
    fn player_name(self: @T, game_id: u64) -> felt252;
    fn xp(self: @T, game_id: u64) -> u16;
}

#[dojo::contract]
pub mod game_systems {
    use darkshuffle::constants::DEFAULT_NS;
    use darkshuffle::models::{
        card::{Card}, config::{GameSettings}, draft::{Draft, DraftOwnerTrait},
        game::{Game, GameActionEvent, GameOwnerTrait, GameState}, map::{Map, MonsterNode},
    };

    use darkshuffle::utils::{
        cards::CardUtilsImpl, config::ConfigUtilsImpl, draft::DraftUtilsImpl, map::MapUtilsImpl, random,
    };

    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use game_components_minigame::interface::{IMinigameDispatcher, IMinigameDispatcherTrait, IMinigameTokenData};
    use game_components_minigame::libs::{assert_token_ownership, post_action, pre_action};

    use game_components_minigame::minigame::MinigameComponent;
    use openzeppelin_introspection::src5::SRC5Component;

    use starknet::{ContractAddress};

    // Components
    component!(path: MinigameComponent, storage: minigame, event: MinigameEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl MinigameImpl = MinigameComponent::MinigameImpl<ContractState>;
    impl MinigameInternalImpl = MinigameComponent::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        minigame: MinigameComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        MinigameEvent: MinigameComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    fn dojo_init(
        ref self: ContractState,
        creator_address: ContractAddress,
        denshokan_address: ContractAddress,
        renderer_address: Option<ContractAddress>,
    ) {
        let mut world: WorldStorage = self.world(@DEFAULT_NS());
        let (config_systems_address, _) = world.dns(@"config_systems").unwrap();

        // Use provided renderer address or default to 'renderer_systems'
        let final_renderer_address = match renderer_address {
            Option::Some(addr) => addr,
            Option::None => {
                let (default_renderer, _) = world.dns(@"renderer_systems").unwrap();
                default_renderer
            },
        };

        self
            .minigame
            .initializer(
                creator_address,
                "Dark Shuffle",
                "Dark Shuffle is a turn-based, collectible card game. Build your deck, battle monsters, and explore a procedurally generated world.",
                "Provable Games",
                "Provable Games",
                "Digital TCG / Deck Building",
                "https://darkshuffle.io/favicon.svg",
                Option::None, // color
                Option::None, // client_url
                Option::Some(final_renderer_address), // renderer address
                Option::Some(config_systems_address), // settings_address
                Option::None, // objectives_address
                denshokan_address,
            );
    }

    // ------------------------------------------ //
    // ------------ Minigame Component ------------------------ //
    // ------------------------------------------ //
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
    impl GameSystemsImpl of super::IGameSystems<ContractState> {
        fn start_game(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            let token_address = _get_token_address(world);
            assert_token_ownership(token_address, game_id);
            pre_action(token_address, game_id);
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

            post_action(token_address, game_id);
        }

        fn pick_card(ref self: ContractState, game_id: u64, option_id: u8) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            let token_address = _get_token_address(world);
            assert_token_ownership(token_address, game_id);
            pre_action(token_address, game_id);

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

            post_action(token_address, game_id);
        }

        fn generate_tree(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            let token_address = _get_token_address(world);
            assert_token_ownership(token_address, game_id);
            pre_action(token_address, game_id);

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

            post_action(token_address, game_id);
        }

        fn select_node(ref self: ContractState, game_id: u64, node_id: u8) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            let token_address = _get_token_address(world);
            assert_token_ownership(token_address, game_id);
            pre_action(token_address, game_id);

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

            post_action(token_address, game_id);
        }

        fn player_name(self: @ContractState, game_id: u64) -> felt252 {
            self.minigame.get_player_name(game_id)
        }

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

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn assert_game_not_started(self: @ContractState, game_id: u64) {
            let game: Game = self.world(@DEFAULT_NS()).read_model(game_id);
            assert!(game.hero_xp == 0, "Dark Shuffle: Game {} has already started", game_id);
        }
    }

    fn _get_token_address(world: WorldStorage) -> ContractAddress {
        let (game_systems_address, _) = world.dns(@"game_systems").unwrap();
        let minigame_dispatcher = IMinigameDispatcher { contract_address: game_systems_address };
        minigame_dispatcher.token_address()
    }
}
