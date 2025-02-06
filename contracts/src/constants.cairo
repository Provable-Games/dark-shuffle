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

fn DEFAULT_NS() -> @ByteArray {
    @"darkshuffle_s1"
}

fn DEFAULT_NS_STR() -> ByteArray {
    "darkshuffle_s1"
}
