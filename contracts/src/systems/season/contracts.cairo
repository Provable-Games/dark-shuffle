#[starknet::interface]
trait ISeasonSystems<T> {
    fn start_season(ref self: T, start_time: u64, duration: u64, entry_amount: u256, settings_id: u32);
    fn end_season(ref self: T, season_id: usize);
    fn donate_season(ref self: T, season_id: usize, amount: u32, name: felt252, social: felt252);
}

#[dojo::contract]
mod season_systems {
    use achievement::store::{Store, StoreTrait};

    use darkshuffle::constants::{DEFAULT_NS, PRIZES, WORLD_CONFIG_ID};
    use darkshuffle::models::config::{GameSettings, GameSettingsTrait, WorldConfig};
    use darkshuffle::models::season::{Donation, Leaderboard, Season, SeasonOwnerTrait};
    use darkshuffle::utils::tasks::index::{Task, TaskTrait};
    use darkshuffle::utils::{season::SeasonUtilsImpl};
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin::token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
    use starknet::{get_caller_address, get_contract_address, get_tx_info};

    #[abi(embed_v0)]
    impl SeasonSystemsImpl of super::ISeasonSystems<ContractState> {
        fn start_season(ref self: ContractState, start_time: u64, duration: u64, entry_amount: u256, settings_id: u32) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let settings: GameSettings = world.read_model(settings_id);
            assert(settings.exists(), 'Invalid settings');

            world
                .write_model(
                    @Season {
                        season_id: world.dispatcher.uuid() + 1,
                        season_address: get_contract_address(),
                        settings_id,
                        start: start_time,
                        end: start_time + duration,
                        entry_amount,
                        reward_pool: 0,
                        finalized: false,
                    },
                );
        }

        fn end_season(ref self: ContractState, season_id: usize) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            let game_token = IERC721Dispatcher { contract_address: world_config.game_token_address };

            let mut season: Season = world.read_model(season_id);
            season.assert_end_season();

            // Distribute prizes
            let chain_id = get_tx_info().unbox().chain_id;
            let payment_dispatcher = IERC20Dispatcher {
                contract_address: SeasonUtilsImpl::get_lords_address(chain_id),
            };
            payment_dispatcher.approve(season.season_address, season.reward_pool);

            let mut i = 1;
            while i <= PRIZES {
                let position: Leaderboard = world.read_model((season_id, i));
                if position.score == 0 {
                    break;
                }

                let reward = season.reward_pool / 100 * SeasonUtilsImpl::get_prize_percentage(i).into();

                let receiever_address = game_token.owner_of(position.game_id.into());
                payment_dispatcher.transfer_from(season.season_address, receiever_address, reward);

                // [Achievement] Legend
                if i < 4 {
                    let player_id: felt252 = receiever_address.into();
                    let task_id: felt252 = Task::Legend.identifier();
                    let time = starknet::get_block_timestamp();
                    let store = StoreTrait::new(world);
                    store.progress(player_id, task_id, count: 1, time: time);
                }

                i += 1;
            };

            // Finalize season
            season.finalized = true;
            world.write_model(@season);
        }

        fn donate_season(ref self: ContractState, season_id: usize, amount: u32, name: felt252, social: felt252) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            let mut season: Season = world.read_model(season_id);
            season.assert_donation(amount.into());

            let chain_id = get_tx_info().unbox().chain_id;
            let address = get_caller_address();

            let payment_dispatcher = IERC20Dispatcher {
                contract_address: SeasonUtilsImpl::get_lords_address(chain_id),
            };
            let amount_with_decimals: u256 = amount.into() * 1000000000000000000;
            payment_dispatcher.transfer_from(get_caller_address(), season.season_address, amount_with_decimals);
            season.reward_pool += amount_with_decimals;

            let mut donation: Donation = world.read_model((season_id, address));
            donation.name = name;
            donation.social = social;
            donation.amount += amount_with_decimals;
            world.write_model(@donation);

            world.write_model(@season);
        }
    }
}
