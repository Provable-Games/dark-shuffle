use darkshuffle::models::card::{CardRarity, CardType, CardEffect};
use darkshuffle::models::config::{GameSettings, CardRarityWeights};
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
        draw_amount: u8,
        card_ids: Span<u64>,
        card_rarity_weights: CardRarityWeights,
        auto_draft: bool,
        persistent_health: bool,
        max_branches: u8,
        enemy_attack: u8,
        enemy_health: u8,
    ) -> u32;

    fn add_random_settings(ref self: T) -> u32;
    fn add_creature_card(ref self: T, name: felt252, rarity: u8, cost: u8, attack: u8, health: u8, card_type: u8, play_effect: CardEffect, death_effect: CardEffect, attack_effect: CardEffect);
    fn add_spell_card(ref self: T, name: felt252, rarity: u8, cost: u8, card_type: u8, effect: CardEffect, extra_effect: CardEffect);

    fn setting_details(self: @T, settings_id: u32) -> GameSettings;
    fn settings_exists(self: @T, settings_id: u32) -> bool;
    fn game_settings(self: @T, game_id: u64) -> GameSettings;
}

#[dojo::contract]
mod config_systems {
    use achievement::components::achievable::AchievableComponent;
    use darkshuffle::constants::DEFAULT_SETTINGS::GET_DEFAULT_SETTINGS;
    use darkshuffle::constants::{DEFAULT_NS, VERSION};
    use darkshuffle::models::card::{CardRarity, CardType, CardEffect};
    use darkshuffle::models::config::{GameSettings, GameSettingsTrait, SettingsCounter, CardRarityWeights, MapSettings, BattleSettings, DraftSettings};
    use darkshuffle::utils::config::ConfigUtilsImpl;
    use darkshuffle::utils::trophies::index::{TROPHY_COUNT, Trophy, TrophyTrait};
    use dojo::model::ModelStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage};
    use starknet::{ContractAddress, get_caller_address};
    use tournaments::components::models::game::TokenMetadata;
    use darkshuffle::utils::random;

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
        let mut world: WorldStorage = self.world(@DEFAULT_NS());
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
        let settings: GameSettings = GET_DEFAULT_SETTINGS();
        world.write_model(@settings);
        ConfigUtilsImpl::create_genesis_cards(ref world);
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
            draw_amount: u8,
            card_ids: Span<u64>,
            card_rarity_weights: CardRarityWeights,
            auto_draft: bool,
            persistent_health: bool,
            max_branches: u8,
            enemy_attack: u8,
            enemy_health: u8,
        ) -> u32 {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            // increment settings counter
            let mut settings_count: SettingsCounter = world.read_model(VERSION);
            settings_count.count += 1;

            let settings: GameSettings = GameSettings {
                settings_id: settings_count.count,
                start_health,
                persistent_health,
                map: MapSettings {
                    max_branches,
                    enemy_attack,
                    enemy_health,
                },
                battle: BattleSettings {
                    start_energy,
                    start_hand_size,
                    max_energy,
                    max_hand_size,
                    draw_amount,
                },
                draft: DraftSettings {
                    draft_size,
                    card_ids,
                    card_rarity_weights,
                    auto_draft,
                },
            };

            self.validate_settings(settings);

            world.write_model(@settings);
            world.write_model(@settings_count);
            settings_count.count
        }

        fn add_random_settings(ref self: ContractState) -> u32 {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());
            let mut settings_count: SettingsCounter = world.read_model(VERSION);
            settings_count.count += 1;

            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);

            let settings: GameSettings = ConfigUtilsImpl::random_settings(settings_count.count, seed);
            world.write_model(@settings);
            world.write_model(@settings_count);
            settings_count.count
        }

        fn add_creature_card(ref self: ContractState, name: felt252, rarity: u8, cost: u8, attack: u8, health: u8, card_type: u8, play_effect: CardEffect, death_effect: CardEffect, attack_effect: CardEffect) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());            
            ConfigUtilsImpl::create_creature_card(ref world, name, rarity, cost, attack, health, card_type, play_effect, death_effect, attack_effect);
        }

        fn add_spell_card(ref self: ContractState, name: felt252, rarity: u8, cost: u8, card_type: u8, effect: CardEffect, extra_effect: CardEffect) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());
            ConfigUtilsImpl::create_spell_card(ref world, name, rarity, cost, card_type, effect, extra_effect);
        }

        fn setting_details(self: @ContractState, settings_id: u32) -> GameSettings {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings
        }

        fn settings_exists(self: @ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings.exists()
        }

        fn game_settings(self: @ContractState, game_id: u64) -> GameSettings {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let token_metadata: TokenMetadata = world.read_model(game_id);
            let game_settings: GameSettings = world.read_model(token_metadata.settings_id);
            game_settings
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn validate_settings(self: @ContractState, settings: GameSettings) {
            assert!(settings.start_health > 0, "Starting health must be greater than 0");
            assert!(settings.start_health <= 200, "Maximum starting health cannot be greater than 200");

            assert!(settings.draft.draft_size > 0, "Draft size must be greater than 0 cards");
            assert!(settings.draft.draft_size <= 50, "Maximum draft size is 50 cards");

            assert!(settings.battle.max_energy > 0, "Maximum energy must be greater than 0");
            assert!(settings.battle.max_energy <= 50, "Maximum energy cannot be greater than 50");

            assert!(settings.battle.start_energy > 0, "Starting energy must be greater than 0");
            assert!(settings.battle.start_energy <= 50, "Maximum starting energy cannot be greater than 50");

            assert!(settings.battle.start_hand_size > 0, "Starting hand size must be greater than 0 cards");
            assert!(settings.battle.start_hand_size <= 10, "Maximum starting hand size cannot be greater than 10 cards");

            assert!(settings.battle.max_hand_size > 0, "Maximum hand size must be greater than 0 cards");
            assert!(settings.battle.max_hand_size <= 10, "Maximum hand size cannot be greater than 10 cards");

            assert!(settings.draft.card_ids.len() >= 3, "Minimum 3 draftable cards");

            assert!(settings.battle.draw_amount > 0, "Draw amount must be greater than 0");
            assert!(settings.battle.draw_amount <= 5, "Maximum draw amount cannot be greater than 5");

            assert!(settings.draft.card_rarity_weights.common <= 10, "Common rarity weight cannot be greater than 10");
            assert!(settings.draft.card_rarity_weights.uncommon <= 10, "Uncommon rarity weight cannot be greater than 10");
            assert!(settings.draft.card_rarity_weights.rare <= 10, "Rare rarity weight cannot be greater than 10");
            assert!(settings.draft.card_rarity_weights.epic <= 10, "Epic rarity weight cannot be greater than 10");
            assert!(settings.draft.card_rarity_weights.legendary <= 10, "Legendary rarity weight cannot be greater than 10");

            assert!(settings.map.max_branches > 0, "Maximum branches must be greater than 0");
            assert!(settings.map.max_branches <= 3, "Maximum branches cannot be greater than 3");

            assert!(settings.map.enemy_attack > 0, "Enemy attack must be greater than 0");
            assert!(settings.map.enemy_attack <= 10, "Enemy attack cannot be greater than 10");

            assert!(settings.map.enemy_health > 10, "Enemy health must be greater than 10");
        }
    }
}
