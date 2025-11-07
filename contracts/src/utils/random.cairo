use core::traits::DivRem;
use darkshuffle::constants::{LCG_PRIME, MAINNET_CHAIN_ID, SEPOLIA_CHAIN_ID, U128_MAX_NZ};

use darkshuffle::utils::cartridge::vrf::{IVrfProviderDispatcher, IVrfProviderDispatcherTrait, Source};
use starknet::{ContractAddress, contract_address_const, get_block_timestamp, get_caller_address, get_tx_info};

pub fn get_vrf_address() -> ContractAddress {
    contract_address_const::<0x051fea4450da9d6aee758bdeba88b2f665bcbf549d2c61421aa724e9ac0ced8f>()
}

pub fn get_random_hash() -> felt252 {
    let chain_id = get_tx_info().unbox().chain_id;

    if chain_id == MAINNET_CHAIN_ID || chain_id == SEPOLIA_CHAIN_ID {
        let vrf_provider = IVrfProviderDispatcher { contract_address: get_vrf_address() };
        vrf_provider.consume_random(Source::Nonce(get_caller_address()))
    } else {
        get_block_timestamp().into()
    }
}

pub fn get_entropy(felt_to_split: felt252) -> u128 {
    let to_u256: u256 = felt_to_split.try_into().unwrap();
    let (_d, r) = DivRem::div_rem(to_u256.low, U128_MAX_NZ.into());

    r.try_into().unwrap() % LCG_PRIME
}

pub fn LCG(seed: u128) -> u128 {
    let a = 25214903917;
    let c = 11;
    let m = LCG_PRIME;

    (a * seed + c) % m
}

pub fn get_random_card_index(seed: u128, card_pool: Span<u8>) -> u8 {
    let index: u32 = (seed % card_pool.len().into()).try_into().unwrap();

    *card_pool.at(index)
}

pub fn get_random_number_zero_indexed(seed: u128, range: u8) -> u8 {
    if range == 0 {
        return 0;
    }

    (seed % range.into()).try_into().unwrap()
}

pub fn get_random_number(seed: u128, range: u8) -> u8 {
    if range == 0 {
        return 0;
    }

    (seed % range.into() + 1).try_into().unwrap()
}
