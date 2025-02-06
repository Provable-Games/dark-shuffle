use darkshuffle::constants::{PRIZES, MAINNET_CHAIN_ID, SEPOLIA_CHAIN_ID};
use darkshuffle::models::game::{Game};
use darkshuffle::models::season::{Leaderboard};
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, contract_address_const};

#[generate_trait]
impl SeasonUtilsImpl of SeasonUtilsTrait {
    fn score_game(ref world: WorldStorage, game: Game) {
        let mut i = PRIZES;

        while i >= 0 {
            let leaderboard: Leaderboard = world.read_model((game.season_id, i));

            if leaderboard.score > game.hero_xp || i == 0 {
                Self::update_leaderboard(ref world, game, i + 1);
                break;
            }

            i -= 1;
        };
    }

    fn update_leaderboard(ref world: WorldStorage, game: Game, rank: u8) {
        if rank > PRIZES {
            return;
        }

        let mut i = rank;
        let mut previous_position: Leaderboard = world.read_model((game.season_id, rank));
        world.write_model(@Leaderboard { season_id: game.season_id, rank, game_id: game.game_id, score: game.hero_xp });

        while true {
            i += 1;

            if i > PRIZES || previous_position.score == 0 {
                break;
            }

            let mut next_position: Leaderboard = world.read_model((game.season_id, i));

            previous_position.rank = i;
            world.write_model(@previous_position);

            previous_position = next_position;
        };
    }

    fn get_prize_percentage(rank: u8) -> u8 {
        if rank == 1 {
            return 35;
        }

        if rank == 2 {
            return 20;
        }

        if rank == 3 {
            return 15;
        }

        if rank == 4 {
            return 10;
        }

        if rank == 5 {
            return 8;
        }

        if rank < 11 {
            return 2;
        }

        0
    }

    fn get_lords_address(chain_id: felt252) -> ContractAddress {
        if chain_id == SEPOLIA_CHAIN_ID {
            contract_address_const::<0x019c92fa87f4d5e3be25c3dd6a284f30282a07e87cd782f5fd387b82c8142017>()
        } else if chain_id == MAINNET_CHAIN_ID {
            contract_address_const::<0x0124aeb495b947201f5fac96fd1138e326ad86195b98df6dec9009158a533b49>()
        } else {
            panic_with_felt252('Chain not supported')
        }
    }

    fn get_velords_address(chain_id: felt252) -> ContractAddress {
        if chain_id == SEPOLIA_CHAIN_ID {
            contract_address_const::<0x01492BB8B748c4a503F3232ba3D9308571bAAbf0F17b48AB17d5D105d61223C9>()
        } else if chain_id == MAINNET_CHAIN_ID {
            contract_address_const::<0x045c587318c9ebcf2fbe21febf288ee2e3597a21cd48676005a5770a50d433c5>()
        } else {
            panic_with_felt252('Chain not supported')
        }
    }

    fn get_pg_address(chain_id: felt252) -> ContractAddress {
        if chain_id == SEPOLIA_CHAIN_ID {
            contract_address_const::<0x0418ed348930686c844fda4556173457d3f71ae547262406d271de534af6b35e>()
        } else if chain_id == MAINNET_CHAIN_ID {
            contract_address_const::<0x000B39b235b44c53a2E9F0c5D35939D9C8E8dAFDd0a2ba2E695b501Fc1e9fd2f>()
        } else {
            panic_with_felt252('Chain not supported')
        }
    }
}
