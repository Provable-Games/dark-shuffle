use cartridge_vrf::{IVrfProviderDispatcher, IVrfProviderDispatcherTrait, Source};

use core::{integer::{u256_try_as_non_zero, U256DivRem},};

use darkshuffle::constants::{CARD_POOL_SIZE, U128_MAX, LCG_PRIME, MAINNET_CHAIN_ID, SEPOLIA_CHAIN_ID};
use starknet::{get_block_timestamp, get_tx_info, ContractAddress, contract_address_const, get_caller_address};

fn get_vrf_address() -> ContractAddress {
    contract_address_const::<0x051fea4450da9d6aee758bdeba88b2f665bcbf549d2c61421aa724e9ac0ced8f>()
}

fn get_random_hash() -> felt252 {
    let chain_id = get_tx_info().unbox().chain_id;
    if chain_id == MAINNET_CHAIN_ID || chain_id == SEPOLIA_CHAIN_ID {
        let vrf_provider = IVrfProviderDispatcher { contract_address: get_vrf_address() };
        return vrf_provider.consume_random(Source::Nonce(get_caller_address()));
    }

    let current_timestamp = get_block_timestamp();
    current_timestamp.into()
}

fn get_entropy(felt_to_split: felt252) -> u128 {
    let (_d, r) = U256DivRem::div_rem(felt_to_split.into(), u256_try_as_non_zero(U128_MAX.into()).unwrap());

    r.try_into().unwrap() % LCG_PRIME
}

fn LCG(seed: u128) -> u128 {
    let a = 25214903917;
    let c = 11;
    let m = LCG_PRIME;

    (a * seed + c) % m
}

fn get_random_card_id(seed: u128, include_spells: bool) -> u8 {
    let range: u128 = if include_spells {
        270
    } else {
        225
    };
    let card_number: u16 = (seed % range + 1).try_into().unwrap();

    // Spells
    if card_number > 255 {
        ((270 - card_number) / 5 + 88).try_into().unwrap()
    } else if card_number > 243 {
        ((255 - card_number) / 4 + 85).try_into().unwrap()
    } else if card_number > 234 {
        ((243 - card_number) / 3 + 82).try_into().unwrap()
    } else if card_number > 228 {
        ((234 - card_number) / 2 + 79).try_into().unwrap()
    } else if card_number > 225 {
        ((228 - card_number) + 76).try_into().unwrap()
    }// Creatures
    else if card_number > 150 {
        ((225 - card_number) / 5 + 61).try_into().unwrap()
    } else if card_number > 90 {
        ((150 - card_number) / 4 + 46).try_into().unwrap()
    } else if card_number > 45 {
        ((90 - card_number) / 3 + 31).try_into().unwrap()
    } else if card_number > 15 {
        ((45 - card_number) / 2 + 16).try_into().unwrap()
    } else {
        card_number.try_into().unwrap()
    }
}

fn get_random_number_zero_indexed(seed: u128, range: u8) -> u8 {
    (seed % range.into()).try_into().unwrap()
}

fn get_random_number(seed: u128, range: u8) -> u8 {
    (seed % range.into() + 1).try_into().unwrap()
}
