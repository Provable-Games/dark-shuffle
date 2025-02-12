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
    );

    fn get_game_token_address(self: @T) -> ContractAddress;
}

#[dojo::contract]
mod config_systems {
    use achievement::components::achievable::AchievableComponent;
    use darkshuffle::constants::{DEFAULT_NS, DEFAULT_SETTINGS::GET_DEFAULT_SETTINGS, VERSION, WORLD_CONFIG_ID};
    use darkshuffle::models::config::{GameSettings, SettingsCounter, WorldConfig};
    use darkshuffle::utils::trophies::index::{TROPHY_COUNT, Trophy, TrophyTrait};
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
        };

        // initialize game with default settings
        world.write_model(GET_DEFAULT_SETTINGS());
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
        ) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            // TODO: add upper bounds assertions
            assert(start_health > 0, 'Invalid start health');
            assert(draft_size > 0, 'Invalid draft size');
            assert(max_energy > 0, 'Invalid max energy');
            assert(max_hand_size > 0, 'Invalid max hand size');

            // increment settings counter
            let mut settings_count: SettingsCounter = world.read_model(VERSION);
            settings_count.count += 1;
            world.write_model(@settings_count);

            world
                .write_model(
                    @GameSettings {
                        settings_id: settings_count.count,
                        start_health,
                        start_energy,
                        start_hand_size,
                        draft_size,
                        max_energy,
                        max_hand_size,
                        include_spells,
                    },
                );
        }

        fn get_game_token_address(self: @ContractState) -> ContractAddress {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);
            world_config.game_token_address
        }
    }
}
