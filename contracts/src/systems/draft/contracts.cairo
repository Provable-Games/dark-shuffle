#[starknet::interface]
trait IDraftSystems<T> {
    fn pick_card(ref self: T, game_id: u64, option_id: u8);
}

#[dojo::contract]
mod draft_systems {
    use darkshuffle::constants::DEFAULT_NS;
    use darkshuffle::models::config::GameSettings;
    use darkshuffle::models::draft::{Draft, DraftOwnerTrait};
    use darkshuffle::models::game::{Game, GameActionEvent, GameOwnerTrait, GameState};
    use darkshuffle::utils::config::ConfigUtilsImpl;
    use darkshuffle::utils::draft::DraftUtilsImpl;
    use darkshuffle::utils::random;
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage};
    use tournaments::components::libs::lifecycle::{LifecycleAssertionsImpl, LifecycleAssertionsTrait};
    use tournaments::components::models::game::TokenMetadata;
    use tournaments::components::models::lifecycle::Lifecycle;

    #[abi(embed_v0)]
    impl DraftSystemsImpl of super::IDraftSystems<ContractState> {
        fn pick_card(ref self: ContractState, game_id: u64, option_id: u8) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            let token_metadata: TokenMetadata = world.read_model(game_id);
            token_metadata.lifecycle.assert_is_playable(game_id, starknet::get_block_timestamp());

            let mut game: Game = world.read_model(game_id);
            game.assert_owner(world);
            game.assert_draft();

            let mut draft: Draft = world.read_model(game_id);
            draft.add_card(*draft.options.at(option_id.into()));

            let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, game_id);
            let current_draft_size = draft.cards.len();

            if current_draft_size == game_settings.draft_size.into() {
                game.state = GameState::Map.into();
                game.action_count = current_draft_size.try_into().unwrap();
                world.write_model(@game);
            } else {
                let random_hash = random::get_random_hash();
                let seed: u128 = random::get_entropy(random_hash);
                let card_pool = DraftUtilsImpl::get_weighted_draft_list(world, game_settings);
                draft.options = DraftUtilsImpl::get_draft_options(seed, card_pool);
            }

            world.write_model(@draft);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id,
                        tx_hash: starknet::get_tx_info().unbox().transaction_hash,
                        count: current_draft_size.try_into().unwrap(),
                    },
                );
            game.update_metadata(world);
        }
    }
}
