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

fn DEFAULT_NS() -> ByteArray {
    "ds_v1_2_0"
}

fn SCORE_MODEL() -> ByteArray {
    "Game"
}

fn SCORE_ATTRIBUTE() -> ByteArray {
    "hero_xp"
}

fn SETTINGS_MODEL() -> ByteArray {
    "GameSettings"
}

pub mod DEFAULT_SETTINGS {
    use darkshuffle::models::config::{GameSettings, CardRarityWeights, MapSettings, BattleSettings, DraftSettings};

    const PERSISTENT_HEALTH: bool = true;
    const AUTO_DRAFT: bool = false;
    const STARTING_HEALTH: u8 = 50;
    const START_ENERGY: u8 = 1;
    const START_HAND_SIZE: u8 = 5;
    const DRAFT_SIZE: u8 = 20;
    const MAX_ENERGY: u8 = 7;
    const MAX_HAND_SIZE: u8 = 10;
    const DRAW_AMOUNT: u8 = 1;
    const POSSIBLE_BRANCHES: u8 = 3;
    const ENEMY_STARTING_ATTACK: u8 = 2;
    const ENEMY_STARTING_HEALTH: u8 = 40;

    fn GET_GENESIS_CARD_IDS() -> Span<u64> {
        let mut card_ids = array![];

        let mut i = 1;
        while i <= 90 {
            card_ids.append(i);
            i += 1;
        };

        card_ids.span()
    }

    fn GET_DEFAULT_WEIGHTS() -> CardRarityWeights {
        CardRarityWeights {
            common: 5,
            uncommon: 4,
            rare: 3,
            epic: 2,
            legendary: 1,
        }
    }

    fn GET_DEFAULT_SETTINGS() -> GameSettings {
        GameSettings {
            settings_id: 0,
            starting_health: STARTING_HEALTH,
            persistent_health: PERSISTENT_HEALTH,
            map: MapSettings {
                possible_branches: POSSIBLE_BRANCHES,
                enemy_starting_attack: ENEMY_STARTING_ATTACK,
                enemy_starting_health: ENEMY_STARTING_HEALTH,
            },
            battle: BattleSettings {
                start_energy: START_ENERGY,
                start_hand_size: START_HAND_SIZE,
                max_energy: MAX_ENERGY,
                max_hand_size: MAX_HAND_SIZE,
                draw_amount: DRAW_AMOUNT,
            },
            draft: DraftSettings {
                card_ids: GET_GENESIS_CARD_IDS(),
                card_rarity_weights: GET_DEFAULT_WEIGHTS(),
                auto_draft: AUTO_DRAFT,
                draft_size: DRAFT_SIZE,
            },
        }
    }
}
