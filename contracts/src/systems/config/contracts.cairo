use darkshuffle::models::config::GameSettings;
use starknet::ContractAddress;

#[starknet::interface]
trait IConfigSystems<T> {
    fn add_settings(
        ref self: T,
        start_health: u8,
        start_energy: u8,
        start_hand_size: u8,
        draft_size: u8,
        max_energy: u8,
        max_hand_size: u8,
        include_spells: bool,
        card_ids: Span<u64>,
    );
    fn setting_details(self: @T, settings_id: u32) -> GameSettings;
    fn settings_exists(self: @T, settings_id: u32) -> bool;
    fn game_settings(self: @T, game_id: u64) -> GameSettings;
}

#[dojo::contract]
mod config_systems {
    use achievement::components::achievable::AchievableComponent;
    use darkshuffle::constants::{DEFAULT_NS, DEFAULT_SETTINGS::GET_DEFAULT_SETTINGS, VERSION};
    use darkshuffle::models::config::{GameSettings, GameSettingsTrait, SettingsCounter};
    use darkshuffle::utils::trophies::index::{TROPHY_COUNT, Trophy, TrophyTrait};
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use starknet::{ContractAddress, get_caller_address};
    use tournaments::components::models::game::{TokenMetadata};

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
        fn add_settings(
            ref self: ContractState,
            start_health: u8,
            start_energy: u8,
            start_hand_size: u8,
            draft_size: u8,
            max_energy: u8,
            max_hand_size: u8,
            include_spells: bool,
            card_ids: Span<u64>,
        ) {
            let mut world: WorldStorage = self.world(DEFAULT_NS());

            // TODO: add upper bounds assertions
            assert(start_health > 0, 'Invalid start health');
            assert(draft_size > 0, 'Invalid draft size');
            assert(max_energy > 0, 'Invalid max energy');
            assert(max_hand_size > 0, 'Invalid max hand size');
            assert(card_ids.len() > 10, 'Minimum 10 card ids required');

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
                        card_ids,
                    }
                );
        }

        fn setting_details(self: @ContractState, settings_id: u32) -> GameSettings {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings
        }

        fn settings_exists(self: @ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings.exists()
        }

        fn game_settings(self: @ContractState, game_id: u64) -> GameSettings {
            let world: WorldStorage = self.world(DEFAULT_NS());
            let token_metadata: TokenMetadata = world.read_model(game_id);
            let game_settings: GameSettings = world.read_model(token_metadata.settings_id);
            game_settings
        }
    }
}
