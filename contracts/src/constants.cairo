const WORLD_CONFIG_ID: u8 = 1;
const CARD_POOL_SIZE: u8 = 75;

const LAST_NODE_DEPTH: u8 = 6;
const PRIZES: u8 = 10;

const MAINNET_CHAIN_ID: felt252 = 0x534e5f4d41494e;
const SEPOLIA_CHAIN_ID: felt252 = 0x534e5f5345504f4c4941;
const KATANA_CHAIN_ID: felt252 = 0x4b4154414e41;

mod Messages {
    const NOT_OWNER: felt252 = 'Not authorized to act';
    const NOT_IN_DRAFT: felt252 = 'Not in draft';
    const GAME_OVER: felt252 = 'Game over';
    const IN_BATTLE: felt252 = 'Already in battle';
    const IN_DRAFT: felt252 = 'Draft not over';
    const BLOCK_REVEAL: felt252 = 'Block not revealed';
    const SCORE_SUBMITTED: felt252 = 'Score already submitted';
}

const U8_MAX: u8 = 255;
const U128_MAX: u128 = 340282366920938463463374607431768211455;
const LCG_PRIME: u128 = 281474976710656;
const VERSION: felt252 = '0.0.1';

fn DEFAULT_NS() -> @ByteArray {
    @"ds"
}

fn DEFAULT_NS_STR() -> ByteArray {
    "ds"
}

pub mod DEFAULT_SETTINGS {
    use darkshuffle::models::config::GameSettings;

    const START_HEALTH: u8 = 50;
    const START_ENERGY: u8 = 1;
    const START_HAND_SIZE: u8 = 5;
    const DRAFT_SIZE: u8 = 20;
    const MAX_ENERGY: u8 = 7;
    const MAX_HAND_SIZE: u8 = 10;
    const INCLUDE_SPELLS: bool = true;

    fn GET_DEFAULT_SETTINGS() -> @GameSettings {
        @GameSettings {
            settings_id: 0,
            start_health: START_HEALTH,
            start_energy: START_ENERGY,
            start_hand_size: START_HAND_SIZE,
            draft_size: DRAFT_SIZE,
            max_energy: MAX_ENERGY,
            max_hand_size: MAX_HAND_SIZE,
            include_spells: INCLUDE_SPELLS,
        }
    }
}
