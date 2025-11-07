// SPDX-License-Identifier: MIT

use game_components_minigame::structs::GameDetail;

#[starknet::interface]
pub trait IRendererSystems<T> {
    fn create_metadata(self: @T, game_id: u64) -> ByteArray;
    fn generate_svg(self: @T, game_id: u64) -> ByteArray;
    fn generate_details(self: @T, game_id: u64) -> Span<GameDetail>;
}

#[dojo::contract]
pub mod renderer_systems {
    use darkshuffle::constants::{DEFAULT_NS};
    use darkshuffle::models::game::GameState;
    use darkshuffle::systems::game::contracts::{IGameSystemsDispatcher, IGameSystemsDispatcherTrait};

    use darkshuffle::utils::{
        cards::CardUtilsImpl, config::ConfigUtilsImpl, draft::DraftUtilsImpl, map::MapUtilsImpl,
        renderer::utils::{create_metadata, create_svg, encode_card_name},
    };

    use dojo::world::{WorldStorageTrait};

    use game_components_minigame::interface::{
        IMinigameDetails, IMinigameDetailsSVG, IMinigameDispatcher, IMinigameDispatcherTrait,
    };
    use game_components_minigame::libs::require_owned_token;
    use game_components_minigame::structs::GameDetail;

    use super::IRendererSystems;


    #[abi(embed_v0)]
    impl GameDetailsImpl of IMinigameDetails<ContractState> {
        fn game_details(self: @ContractState, token_id: u64) -> Span<GameDetail> {
            self.validate_token_ownership(token_id);
            self.generate_details(token_id)
        }

        fn token_name(self: @ContractState, token_id: u64) -> ByteArray {
            self.validate_token_ownership(token_id);
            "Dark Shuffle Game"
        }

        fn token_description(self: @ContractState, token_id: u64) -> ByteArray {
            self.validate_token_ownership(token_id);
            "Dark Shuffle is a roguelike deck-building game. Build your deck, battle monsters, and explore a procedurally generated world."
        }
    }

    #[abi(embed_v0)]
    impl GameDetailsSVGImpl of IMinigameDetailsSVG<ContractState> {
        fn game_details_svg(self: @ContractState, token_id: u64) -> ByteArray {
            self.validate_token_ownership(token_id);
            self.generate_svg(token_id)
        }
    }

    #[abi(embed_v0)]
    impl RendererSystemsImpl of IRendererSystems<ContractState> {
        fn create_metadata(self: @ContractState, game_id: u64) -> ByteArray {
            let (hero_name, hero_health, hero_xp, game_state, cards) = self.get_game_details(game_id);
            create_metadata(game_id, hero_name, hero_health, hero_xp, game_state.into(), cards)
        }

        fn generate_svg(self: @ContractState, game_id: u64) -> ByteArray {
            let (hero_name, hero_health, hero_xp, game_state, cards) = self.get_game_details(game_id);
            create_svg(game_id, hero_name, hero_health, hero_xp, game_state.into(), cards)
        }

        fn generate_details(self: @ContractState, game_id: u64) -> Span<GameDetail> {
            let (_, hero_health, hero_xp, _, cards) = self.get_game_details(game_id);

            let mut details = array![
                GameDetail { name: "XP", value: format!("{}", hero_xp) },
                GameDetail { name: "Health", value: format!("{}", hero_health) },
            ];

            let mut i = 0;
            while i < cards.len() {
                let card_name: felt252 = *cards.at(i);
                let encoded_card_name = encode_card_name(card_name);
                details.append(GameDetail { name: format!("Card #{}", (i + 1).clone()), value: encoded_card_name });
                i += 1;
            };

            details.span()
        }
    }

    #[generate_trait]
    impl RendererSystemsInternal of RendererSystemsInternalTrait {
        fn get_game_details(self: @ContractState, game_id: u64) -> (felt252, u8, u16, GameState, Span<felt252>) {
            let mut world = self.world(@DEFAULT_NS());
            let (game_systems_address, _) = world.dns(@"game_systems").unwrap();
            let game_dispatcher = IGameSystemsDispatcher { contract_address: game_systems_address };

            let hero_name = game_dispatcher.player_name(game_id);
            let hero_health = game_dispatcher.health(game_id);
            let hero_xp = game_dispatcher.xp(game_id);
            let game_state = game_dispatcher.game_state(game_id);
            let cards = game_dispatcher.cards(game_id);

            (hero_name, hero_health, hero_xp, game_state, cards)
        }

        fn validate_token_ownership(self: @ContractState, token_id: u64) {
            let mut world = self.world(@DEFAULT_NS());
            let (game_systems_address, _) = world.dns(@"game_systems").unwrap();
            let minigame_dispatcher = IMinigameDispatcher { contract_address: game_systems_address };
            let token_address = minigame_dispatcher.token_address();
            require_owned_token(token_address, token_id);
        }
    }
}
