use starknet::ContractAddress;

#[starknet::interface]
trait IConfigSystems<T> {
    fn create_game_settings(
        ref self: T,
        start_health: u8,
        start_energy: u8,
        start_hand_size: u8,
        draft_size: u8,
        max_energy: u8,
        max_hand_size: u8,
        include_spells: bool,
        card_ids_allowed: Span<u64>,
    );

    fn set_game_token_address(ref self: T, game_token_address: ContractAddress);
    fn get_game_token_address(self: @T) -> ContractAddress;
}

#[dojo::contract]
mod config_systems {
    use achievement::components::achievable::AchievableComponent;
    use darkshuffle::constants::{DEFAULT_NS, WORLD_CONFIG_ID};
    use darkshuffle::models::config::{GameSettings, WorldConfig};
    use darkshuffle::utils::trophies::index::{Trophy, TrophyTrait, TROPHY_COUNT};
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use starknet::{ContractAddress, get_caller_address};

    component!(path: AchievableComponent, storage: achievable, event: AchievableEvent);
    impl AchievableInternalImpl = AchievableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        achievable: AchievableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AchievableEvent: AchievableComponent::Event,
    }

    fn dojo_init(self: @ContractState) {
        let mut world: WorldStorage = self.world(DEFAULT_NS());
        let mut trophy_id: u8 = TROPHY_COUNT;

        while trophy_id > 0 {
            let trophy: Trophy = trophy_id.into();
            self
                .achievable
                .create(
                    world,
                    id: trophy.identifier(),
                    hidden: trophy.hidden(),
                    index: trophy.index(),
                    points: trophy.points(),
                    start: 0,
                    end: 0,
                    group: trophy.group(),
                    icon: trophy.icon(),
                    title: trophy.title(),
                    description: trophy.description(),
                    tasks: trophy.tasks(),
                    data: trophy.data(),
                );

            trophy_id -= 1;
        }
    }

    #[abi(embed_v0)]
    impl ConfigSystemsImpl of super::IConfigSystems<ContractState> {
        fn create_game_settings(
            ref self: ContractState,
            start_health: u8,
            start_energy: u8,
            start_hand_size: u8,
            draft_size: u8,
            max_energy: u8,
            max_hand_size: u8,
            include_spells: bool,
            card_ids_allowed: Span<u64>,
        ) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            assert(start_health > 0, 'Invalid start health');
            assert(draft_size > 0, 'Invalid draft size');
            assert(max_energy > 0, 'Invalid max energy');
            assert(max_hand_size > 0, 'Invalid max hand size');
            assert(card_ids_allowed.len() > 10, 'Minimum 10 card ids required');

            world
                .write_model(
                    @GameSettings {
                        settings_id: world.dispatcher.uuid() + 1,
                        start_health,
                        start_energy,
                        start_hand_size,
                        draft_size,
                        max_energy,
                        max_hand_size,
                        include_spells,
                        card_ids_allowed,
                    }
                );
        }

        fn set_game_token_address(ref self: ContractState, game_token_address: ContractAddress) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());
            assert(
                world.dispatcher.is_owner(selector_from_tag!("darkshuffle_s1-game_systems"), get_caller_address()),
                'Not Owner'
            );

            let mut world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            world_config.game_token_address = game_token_address;
            world.write_model(@world_config);
        }

        fn get_game_token_address(self: @ContractState) -> ContractAddress {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            world_config.game_token_address
        }
    }
}
