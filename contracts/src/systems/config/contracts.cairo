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

    fn set_game_token_address(ref self: T, game_token_address: felt252);
    fn get_game_token_address(self: @T) -> ContractAddress;
}

#[dojo::contract]
mod config_systems {
    use achievement::components::achievable::AchievableComponent;
    use darkshuffle::constants::{DEFAULT_NS, WORLD_CONFIG_ID};
    use darkshuffle::models::config::{SettingDetails, SettingsCount, WorldConfig};
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

        // TODO: Make stock game settings a constant
        world
            .write_model(
                @SettingDetails {
                    settings_id: 0,
                    start_health: 50,
                    start_energy: 1,
                    start_hand_size: 5,
                    draft_size: 20,
                    max_energy: 7,
                    max_hand_size: 10,
                    include_spells: true,
                },
            );
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

            assert(start_health > 0, 'Invalid start health');
            assert(draft_size > 0, 'Invalid draft size');
            assert(max_energy > 0, 'Invalid max energy');
            assert(max_hand_size > 0, 'Invalid max hand size');

            // TODO: replace with a constant
            let mut settings_count: SettingsCount = world.read_model('1');
            settings_count.count += 1;
            world.write_model(@settings_count);

            world
                .write_model(
                    @SettingDetails {
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

        // TODO: Remove as the NFT is now embedded in game_systems contract
        fn set_game_token_address(ref self: ContractState, game_token_address: felt252) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());
            assert(
                world.dispatcher.is_owner(selector_from_tag!("ds-game_systems"), get_caller_address(),), 'Not Owner',
            );

            let mut world_config: WorldConfig = world.read_model(WORLD_CONFIG_ID);

            let game_token_address: ContractAddress = game_token_address.try_into().unwrap();
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
