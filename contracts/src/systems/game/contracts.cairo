use darkshuffle::models::config::{SettingDetails};
use darkshuffle::models::game::{Game};
use starknet::ContractAddress;

#[starknet::interface]
trait IGameSystems<T> {
    fn start(ref self: T, game_id: u64);
    fn quit(ref self: T, game_id: u64);
    fn setting_details(self: @T, settings_id: u32) -> SettingDetails;
    fn game_details(self: @T, token_id: u128) -> (felt252, u8, u16, u32, u8, Span<felt252>);
}

#[dojo::contract]
mod game_systems {
    use achievement::store::{Store, StoreTrait};

    use darkshuffle::constants::{
        DEFAULT_NS, DEFAULT_NS_STR, LAST_NODE_DEPTH, MAINNET_CHAIN_ID, SEPOLIA_CHAIN_ID, WORLD_CONFIG_ID
    };
    use darkshuffle::interface::{IGameTokenDispatcher, IGameTokenDispatcherTrait};
    use darkshuffle::models::battle::{Card};
    use darkshuffle::models::config::{SettingDetails, SettingDetailsTrait, WorldConfig};
    use darkshuffle::models::draft::{Draft};
    use darkshuffle::models::game::{Game, GameActionEvent, GameOwnerTrait, GameState};
    use darkshuffle::models::season::{Season, SeasonOwnerTrait};
    use darkshuffle::utils::tasks::index::{Task, TaskTrait};
    use darkshuffle::utils::{cards::CardUtilsImpl, draft::DraftUtilsImpl, random, season::SeasonUtilsImpl};
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin_token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::{ContractAddress, get_caller_address, get_tx_info};
    use tournaments::components::game::{IGame, IGameDetails, ISettings, game_component};
    use tournaments::components::models::game::{TokenMetadata};

    component!(path: game_component, storage: game, event: GameEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);

    #[abi(embed_v0)]
    impl GameImpl = game_component::GameImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;

    impl GameInternalImpl = game_component::InternalImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

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

    fn dojo_init(ref self: ContractState) {
        self.erc721.initializer("Dark Shuffle", "DARK", "darkshuffle.dev");
        self
            .game
            .initializer(
                'Dark Shuffle',
                "A deck building game",
                'Provable Games',
                'Provable Games',
                'Deck Building',
                "https://github.com/Provable-Games/dark-shuffle/blob/feat/integrate-tournament/client/public/favicon.svg",
                DEFAULT_NS_STR(),
            );
    }

    #[abi(embed_v0)]
    impl SettingsImpl of ISettings<ContractState> {
        fn setting_exists(self: @ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let settings: SettingDetails = world.read_model(settings_id);
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
        // TODO:
        // 1. Account for fact that game token is now part of this system
        // 2. Remove season code
        fn start(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let token_metadata: TokenMetadata = world.read_model(game_id);
            self.validate_start_conditions(game_id, @token_metadata);

            let game_settings: SettingDetails = world.read_model(token_metadata.settings_id);
            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);
            let action_count = 0;

            world
                .write_model(
                    @Game {
                        game_id,
                        season_id: 0, // TODO: Remove
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

            let options = DraftUtilsImpl::get_draft_options(seed, game_settings.include_spells);
            world.write_model(@Draft { game_id, options, cards: array![].span() });

            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: action_count,
                    },
                );
        }

        fn quit(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let mut game: Game = world.read_model(game_id);
            game.assert_owner(world);

            game.state = GameState::Over;
            game.hero_health = 0;
            game.action_count += 1;

            let mut season: Season = world.read_model(game.season_id);
            if season.season_id != 0 && season.is_active() {
                SeasonUtilsImpl::score_game(ref world, game);
            }

            world.write_model(@game);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: game.action_count,
                    },
                );
        }

        fn setting_details(self: @ContractState, settings_id: u32) -> SettingDetails {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let settings: SettingDetails = world.read_model(settings_id);
            settings
        }

        fn game_details(self: @ContractState, token_id: u128) -> (felt252, u8, u16, u32, u8, Span<felt252>) {
            let world: WorldStorage = self.world(DEFAULT_NS());

            let game: Game = world.read_model(token_id);
            let token_metadata: TokenMetadata = world.read_model(token_id);
            let draft: Draft = world.read_model(token_id);

            /// TODO: make this a util function
            let mut cards = array![];
            let mut i = 0;
            while i < draft.cards.len() {
                let card: Card = CardUtilsImpl::get_card(*draft.cards.at(i));
                cards.append(card.name);
                i += 1;
            };

            (
                token_metadata.player_name,
                game.hero_health,
                game.hero_xp,
                game.season_id,
                game.state.into(),
                cards.span(),
            )
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn validate_start_conditions(self: @ContractState, token_id: u64, token_metadata: @TokenMetadata) {
            self.assert_token_ownership(token_id);
            self.assert_game_not_started(token_id);
            self.assert_game_is_available(token_id, *token_metadata.available_at);
            self.assert_game_not_expired(token_id, *token_metadata.expires_at);
        }

        #[inline(always)]
        fn assert_token_ownership(self: @ContractState, token_id: u64) {
            let token_owner = ERC721MixinImpl::owner_of(self, token_id.into());
            assert!(
                token_owner == starknet::get_caller_address(), "Dark Shuffle: Caller is not owner of token {}", token_id
            );
        }

        #[inline(always)]
        fn assert_game_not_started(self: @ContractState, game_id: u64) {
            let game: Game = self.world(DEFAULT_NS()).read_model(game_id);
            assert!(game.hero_xp == 0, "Dark Shuffle: Game {} has already started", game_id);
        }

        #[inline(always)]
        fn assert_game_not_expired(self: @ContractState, game_id: u64, expires_at: u64) {
            let current_timestamp = starknet::get_block_timestamp();
            if expires_at != 0 {
                assert!(current_timestamp < expires_at, "Dark Shuffle: Game {} expired at {}", game_id, expires_at);
            }
        }

        #[inline(always)]
        fn assert_game_is_available(self: @ContractState, game_id: u64, available_at: u64) {
            let current_timestamp = starknet::get_block_timestamp();
            if available_at != 0 {
                assert!(
                    current_timestamp > available_at,
                    "Dark Shuffle: Game {} is not playable until {}",
                    game_id,
                    available_at
                );
            }
        }
    }
}
