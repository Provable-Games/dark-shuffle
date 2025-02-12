use darkshuffle::models::config::{GameSettings};
use darkshuffle::models::game::{Game};
use starknet::ContractAddress;

#[starknet::interface]
trait IGameSystems<T> {
    fn start_game(ref self: T, game_id: u64);
    fn abandon_game(ref self: T, game_id: u64);
    fn get_settings(self: @T, settings_id: u32) -> GameSettings;
    fn settings_exists(self: @T, settings_id: u32) -> bool;
    fn get_game_settings(self: @T, game_id: u64) -> GameSettings;
    fn get_game_data(self: @T, token_id: u128) -> (felt252, u8, u16, u8, Span<felt252>);
}

#[dojo::contract]
mod game_systems {
    use achievement::store::{Store, StoreTrait};

    use darkshuffle::constants::{
        DEFAULT_NS, DEFAULT_NS_STR, LAST_NODE_DEPTH, MAINNET_CHAIN_ID, SEPOLIA_CHAIN_ID, WORLD_CONFIG_ID,
    };
    use darkshuffle::interface::{IGameTokenDispatcher, IGameTokenDispatcherTrait};
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
    use tournaments::components::game::{IGame, IGameDetails, ISettings, game_component};
    use tournaments::components::models::game::{TokenMetadata};

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
            let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, game_id);
            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);
            let options = DraftUtilsImpl::get_draft_options(seed, game_settings.include_spells);
            let action_count = 0;

            world
                .write_model(
                    @Game {
                        game_id,
                        state: GameState::Draft,
                        hero_health: game_settings.start_health,
                        hero_xp: 1,
                        monsters_slain: 0,
                        map_level: 0,
                        map_depth: LAST_NODE_DEPTH,
                        last_node_id: 0,
                        action_count,
                    },
                );

            world.write_model(@Draft { game_id, options, cards: array![].span() });

            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: action_count,
                    },
                );
        }

        fn abandon_game(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let mut game: Game = world.read_model(game_id);
            game.assert_owner(world);

            game.state = GameState::Over;
            game.hero_health = 0;
            game.action_count += 1;

            world.write_model(@game);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: game.action_count,
                    },
                );
        }

        fn get_settings(self: @ContractState, settings_id: u32) -> GameSettings {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings
        }

        fn settings_exists(self: @ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings.exists()
        }

        fn get_game_settings(self: @ContractState, game_id: u64) -> GameSettings {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let token_metadata: TokenMetadata = world.read_model(game_id);
            let game_settings: GameSettings = world.read_model(token_metadata.settings_id);
            game_settings
        }

        fn get_game_data(self: @ContractState, token_id: u128) -> (felt252, u8, u16, u8, Span<felt252>) {
            let world: WorldStorage = self.world(DEFAULT_NS());

            let game: Game = world.read_model(token_id);
            let draft: Draft = world.read_model(game.game_id);
            let mut cards = array![];

            let mut i = 0;
            while i < draft.cards.len() {
                let card: Card = CardUtilsImpl::get_card(*draft.cards.at(i));
                cards.append(card.name);
                i += 1;
            };

            let token_metadata: TokenMetadata = world.read_model(token_id);
            let player_name = token_metadata.player_name;

            (player_name, game.hero_health, game.hero_xp, game.state.into(), cards.span())
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
            let (hero_name, hero_health, hero_xp, state, cards) = self.get_game_data(token_id.try_into().unwrap());
            create_metadata(token_id, hero_name, hero_health, hero_xp, state, cards)
        }
    }
}
