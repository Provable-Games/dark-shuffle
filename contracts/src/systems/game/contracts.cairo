use darkshuffle::models::config::{GameSettings};
use darkshuffle::models::game::{Game};
use starknet::ContractAddress;

#[starknet::interface]
trait IGameSystems<T> {
    fn mint(ref self: T, settings_id: u32);
    fn enter_season(ref self: T, game_id: u64, season_id: u32);
    fn start_game(ref self: T, game_id: u64, name: felt252);
    fn abandon_game(ref self: T, game_id: u64);

    fn score(self: @T, game_id: u64) -> u16;
    fn get_settings(self: @T, settings_id: u32) -> GameSettings;
    fn settings_exists(self: @T, settings_id: u32) -> bool;
    fn get_game_settings(self: @T, game_id: u64) -> GameSettings;
    fn get_game_data(self: @T, token_id: u128) -> (felt252, u8, u16, u32, u8, Span<felt252>);
    fn get_player_games(self: @T, player_address: ContractAddress, limit: u256, page: u256, active: bool) -> Span<Game>;
}

#[dojo::contract]
mod game_systems {
    use achievement::store::{Store, StoreTrait};

    use darkshuffle::constants::{DEFAULT_NS, LAST_NODE_DEPTH, MAINNET_CHAIN_ID, SEPOLIA_CHAIN_ID, WORLD_CONFIG_ID};
    use darkshuffle::interface::{IGameTokenDispatcher, IGameTokenDispatcherTrait};
    use darkshuffle::models::battle::{Card};
    use darkshuffle::models::config::{GameSettings, GameSettingsTrait, WorldConfig};
    use darkshuffle::models::draft::{Draft};
    use darkshuffle::models::game::{Game, GameActionEvent, GameFixedData, GameOwnerTrait, GameState};
    use darkshuffle::models::season::{Season, SeasonOwnerTrait};
    use darkshuffle::utils::tasks::index::{Task, TaskTrait};
    use darkshuffle::utils::{cards::CardUtilsImpl, draft::DraftUtilsImpl, random, season::SeasonUtilsImpl};
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};

    use openzeppelin::token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_tx_info};

    #[abi(embed_v0)]
    impl GameSystemsImpl of super::IGameSystems<ContractState> {
        fn mint(ref self: ContractState, settings_id: u32) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let settings: GameSettings = world.read_model(settings_id);
            assert(settings.exists(), 'Invalid settings');

            let mut world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            world_config.game_count += 1;
            world.write_model(@world_config);

            let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };
            game_token.mint(get_caller_address(), world_config.game_count.into(), settings_id);
        }

        fn enter_season(ref self: ContractState, game_id: u64, season_id: u32) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let mut season: Season = world.read_model(season_id);
            assert(season.is_active(), 'Season not active');

            let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };

            let settings_id = game_token.settings_id(game_id.into());
            assert(settings_id == season.settings_id, 'Invalid settings');

            let mut game: Game = world.read_model(game_id);
            assert(!game.exists(), 'Game already started');

            let fee_distribution = season.entry_amount / 100 * 5;
            let season_distribution = season.entry_amount / 100 * 90;

            let chain_id = get_tx_info().unbox().chain_id;
            let payment_dispatcher = IERC20Dispatcher {
                contract_address: SeasonUtilsImpl::get_lords_address(chain_id),
            };
            // veLORDS
            payment_dispatcher
                .transfer_from(get_caller_address(), SeasonUtilsImpl::get_velords_address(chain_id), fee_distribution);
            // PG FEE
            payment_dispatcher
                .transfer_from(get_caller_address(), SeasonUtilsImpl::get_pg_address(chain_id), fee_distribution);
            // SEASON POOL
            payment_dispatcher.transfer_from(get_caller_address(), season.season_address, season_distribution);

            season.reward_pool += season_distribution;
            world.write_model(@season);

            game_token.attach_season_pass(game_id.into(), season_id);

            // [Achievement] Play a game
            let player_id: felt252 = get_caller_address().into();
            let task_id: felt252 = Task::Seasoned.identifier();
            let time = starknet::get_block_timestamp();
            let store = StoreTrait::new(world);
            store.progress(player_id, task_id, count: 1, time: time);
        }

        fn start_game(ref self: ContractState, game_id: u64, name: felt252) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };
            let game_settings: GameSettings = world.read_model(game_token.settings_id(game_id.into()));

            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);
            let options = DraftUtilsImpl::get_draft_options(seed, game_settings.include_spells);
            let season_id = game_token.season_pass(game_id.into());
            let action_count = 0;

            world.write_model(@GameFixedData { game_id, player_name: name });

            world
                .write_model(
                    @Game {
                        game_id,
                        season_id,
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

        fn score(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_xp
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

            let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };
            let game_settings: GameSettings = world.read_model(game_token.settings_id(game_id.into()));

            game_settings
        }

        fn get_game_data(self: @ContractState, token_id: u128) -> (felt252, u8, u16, u32, u8, Span<felt252>) {
            let world: WorldStorage = self.world(DEFAULT_NS());

            let game: Game = world.read_model(token_id);
            let game_fixed_data: GameFixedData = world.read_model(game.game_id);
            let draft: Draft = world.read_model(game.game_id);
            let mut cards = array![];

            let mut i = 0;
            while i < draft.cards.len() {
                let card: Card = CardUtilsImpl::get_card(*draft.cards.at(i));
                cards.append(card.name);
                i += 1;
            };

            (
                game_fixed_data.player_name,
                game.hero_health,
                game.hero_xp,
                game.season_id,
                game.state.into(),
                cards.span(),
            )
        }

        fn get_player_games(
            self: @ContractState, player_address: ContractAddress, limit: u256, page: u256, active: bool,
        ) -> Span<Game> {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);

            let game_token = IGameTokenDispatcher { contract_address: world_config.game_token_address };
            let game_token_dispatcher = IERC721Dispatcher { contract_address: world_config.game_token_address };

            let mut balance = game_token_dispatcher.balance_of(player_address);
            let mut last_index = balance - (page * limit);

            let mut games = array![];
            let mut i = last_index;
            let mut game_count = 0;

            while i > 0 && game_count < limit {
                i -= 1;

                let token_id: u128 = game_token.get_token_of_owner_by_index(player_address, i).try_into().unwrap();
                let game: Game = world.read_model(token_id);

                if (active && game.state == GameState::Over) || (!active && game.state != GameState::Over) {
                    continue;
                }

                games.append(game);
                game_count += 1;
            };

            games.span()
        }
    }
}
