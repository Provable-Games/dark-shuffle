use starknet::{ContractAddress, get_block_timestamp};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Season {
    #[key]
    season_id: u32,
    season_address: ContractAddress,
    settings_id: u32,
    start: u64,
    end: u64,
    entry_amount: u256,
    reward_pool: u256,
    finalized: bool,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Leaderboard {
    #[key]
    season_id: u32,
    #[key]
    rank: u8,
    game_id: u64,
    score: u16,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Donation {
    #[key]
    season_id: u32,
    #[key]
    address: ContractAddress,
    name: felt252,
    social: felt252,
    amount: u256
}

#[generate_trait]
impl SeasonOwnerImpl of SeasonOwnerTrait {
    fn is_active(self: Season) -> bool {
        let current_time = get_block_timestamp();
        current_time >= self.start && current_time < self.end
    }

    fn assert_end_season(self: Season) {
        let current_time = get_block_timestamp();
        assert(current_time > self.end, 'Season not over');
        assert(!self.finalized, 'Season has been finalized');
    }

    fn assert_donation(self: Season, amount: u256) {
        assert(!self.finalized, 'Season has been finalized');
        assert(amount >= 10, 'Minimum donation is 10 $LORDS');
    }
}