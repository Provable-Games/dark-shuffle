use darkshuffle::models::config::{GameSettings};
use darkshuffle::models::game::{Game, GameState};
use starknet::ContractAddress;

#[starknet::interface]
trait IGameSystems<T> {
    fn start_game(ref self: T, game_id: u64);
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
mod game_systems {
    use achievement::store::{Store, StoreTrait};

    use darkshuffle::constants::{DEFAULT_NS, DEFAULT_NS_STR, LAST_NODE_DEPTH, WORLD_CONFIG_ID};
    use darkshuffle::models::battle::{Card};
    use darkshuffle::models::config::{GameSettings, GameSettingsTrait, WorldConfig};
    use darkshuffle::models::draft::{Draft};
    use darkshuffle::models::game::{Game, GameActionEvent, GameOwnerTrait, GameState};
    use darkshuffle::utils::renderer::utils::create_metadata;
    use darkshuffle::utils::tasks::index::{Task, TaskTrait};
    use darkshuffle::utils::{cards::CardUtilsImpl, config::ConfigUtilsImpl, draft::DraftUtilsImpl, random};
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};

    use openzeppelin::token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait, IERC721Metadata};

    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_tx_info};
    use tournaments::components::game::game_component;
    use tournaments::components::interfaces::{IGameDetails, IGameToken, ISettings};
    use tournaments::components::libs::lifecycle::{LifecycleAssertionsImpl, LifecycleAssertionsTrait};
    use tournaments::components::models::game::{TokenMetadata};
    use tournaments::components::models::lifecycle::{Lifecycle};

    component!(path: game_component, storage: game, event: GameEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);

    #[abi(embed_v0)]
    impl GameImpl = game_component::GameImpl<ContractState>;
    impl GameInternalImpl = game_component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnlyImpl = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        game: game_component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        GameEvent: game_component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    fn dojo_init(ref self: ContractState, creator_address: ContractAddress) {
        self.erc721.initializer("Dark Shuffle", "DARK", "darkshuffle.dev");
        self
            .game
            .initializer(
                creator_address,
                'Dark Shuffle',
                "A deck building game",
                'Provable Games',
                'Provable Games',
                'Deck Building',
                "https://github.com/Provable-Games/dark-shuffle/blob/feat/integrate-tournament/client/public/favicon.svg",
                DEFAULT_NS_STR(),
            );

        // TODO: We shouldn't need to store this as the token address is the game system address which is already being
        // stored
        let mut world: WorldStorage = self.world(DEFAULT_NS());
        let mut world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
        world_config.game_token_address = get_contract_address();
        world.write_model(@world_config);
    }

    #[abi(embed_v0)]
    impl SettingsImpl of ISettings<ContractState> {
        fn setting_exists(self: @ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings.exists()
        }
    }

    #[abi(embed_v0)]
    impl GameDetailsImpl of IGameDetails<ContractState> {
        fn score(self: @ContractState, game_id: u64) -> u32 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_xp.into()
        }
    }

    #[abi(embed_v0)]
    impl GameSystemsImpl of super::IGameSystems<ContractState> {
        fn start_game(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let token_metadata: TokenMetadata = world.read_model(game_id);
            self.validate_start_conditions(game_id, @token_metadata);

            let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, game_id);
            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);
            let options = DraftUtilsImpl::get_draft_options(seed, game_settings.include_spells);
            let action_count = 0;

            let game = Game {
                game_id,
                state: GameState::Draft.into(),
                hero_health: game_settings.start_health,
                hero_xp: 1,
                monsters_slain: 0,
                map_level: 0,
                map_depth: LAST_NODE_DEPTH,
                last_node_id: 0,
                action_count,
            };

            world.write_model(@game);
            world.write_model(@Draft { game_id, options, cards: array![].span() });

            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: action_count,
                    },
                );
            game.update_metadata(world);
        }

        fn player_name(self: @ContractState, game_id: u64) -> felt252 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let token_metadata: TokenMetadata = world.read_model(game_id);
            token_metadata.player_name
        }

        fn health(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_health
        }

        fn game_state(self: @ContractState, game_id: u64) -> GameState {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.state.into()
        }

        fn xp(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_xp
        }

        fn cards(self: @ContractState, game_id: u64) -> Span<felt252> {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let draft: Draft = world.read_model(game_id);
            let mut cards = array![];

            let mut i = 0;
            while i < draft.cards.len() {
                let card: Card = CardUtilsImpl::get_card(*draft.cards.at(i));
                cards.append(card.name);
                i += 1;
            };

            cards.span()
        }

        fn monsters_slain(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.monsters_slain
        }

        fn level(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.map_level
        }

        fn map_depth(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.map_depth
        }

        fn last_node_id(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.last_node_id
        }

        fn action_count(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.action_count
        }
    }

    #[abi(embed_v0)]
    impl ERC721Metadata of IERC721Metadata<ContractState> {
        /// Returns the NFT name.
        fn name(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_name.read()
        }

        /// Returns the NFT symbol.
        fn symbol(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_symbol.read()
        }

        /// Returns the Uniform Resource Identifier (URI) for the `token_id` token.
        /// If the URI is not set, the return value will be an empty ByteArray.
        ///
        /// Requirements:
        ///
        /// - `token_id` exists.
        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self.erc721._require_owned(token_id);

            let token_id_u64 = token_id.try_into().unwrap();

            let hero_name = self.player_name(token_id_u64);
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
        fn validate_start_conditions(self: @ContractState, token_id: u64, token_metadata: @TokenMetadata) {
            self.assert_token_ownership(token_id);
            self.assert_game_not_started(token_id);
            token_metadata.lifecycle.assert_is_playable(token_id, starknet::get_block_timestamp());
        }

        #[inline(always)]
        fn assert_token_ownership(self: @ContractState, token_id: u64) {
            let token_owner = ERC721Impl::owner_of(self, token_id.into());
            assert!(
                token_owner == starknet::get_caller_address(),
                "Dark Shuffle: Caller is not owner of token {}",
                token_id,
            );
        }

        #[inline(always)]
        fn assert_game_not_started(self: @ContractState, game_id: u64) {
            let game: Game = self.world(DEFAULT_NS()).read_model(game_id);
            assert!(game.hero_xp == 0, "Dark Shuffle: Game {} has already started", game_id);
        }
    }
}
