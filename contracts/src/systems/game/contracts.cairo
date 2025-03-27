use darkshuffle::models::card::{CardRarity, CardType, CardEffect};
use darkshuffle::models::config::{GameSettingsMetadata, GameSettings, CardRarityWeights};
use darkshuffle::models::game::{Game, GameState};
use starknet::ContractAddress;

#[starknet::interface]
trait IGameSystems<T> {
    fn start_game(ref self: T, game_id: u64);
    fn pick_card(ref self: T, game_id: u64, option_id: u8);
    fn generate_tree(ref self: T, game_id: u64);
    fn select_node(ref self: T, game_id: u64, node_id: u8);
    fn battle_actions(ref self: T, game_id: u64, battle_id: u16, actions: Span<Span<u8>>);
    fn add_settings(
        ref self: T,
        name: felt252,
        description: ByteArray,
        starting_health: u8,
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
        possible_branches: u8,
        level_depth: u8,
        enemy_attack_min: u8,
        enemy_attack_max: u8,
        enemy_health_min: u8,
        enemy_health_max: u8,
        enemy_attack_scaling: u8,
        enemy_health_scaling: u8,
    ) -> u32;
    fn add_random_settings(ref self: T) -> u32;
    fn add_creature_card(ref self: T, name: felt252, rarity: u8, cost: u8, attack: u8, health: u8, card_type: u8, play_effect: CardEffect, death_effect: CardEffect, attack_effect: CardEffect);
    fn add_spell_card(ref self: T, name: felt252, rarity: u8, cost: u8, card_type: u8, effect: CardEffect, extra_effect: CardEffect);

    fn action_count(self: @T, game_id: u64) -> u16;
    fn cards(self: @T, game_id: u64) -> Span<felt252>;
    fn game_state(self: @T, game_id: u64) -> GameState;
    fn health(self: @T, game_id: u64) -> u8;
    fn last_node_id(self: @T, game_id: u64) -> u8;
    fn level(self: @T, game_id: u64) -> u8;
    fn map_depth(self: @T, game_id: u64) -> u8;
    fn monsters_slain(self: @T, game_id: u64) -> u16;
    fn player_name(self: @T, game_id: u64) -> felt252;
    fn xp(self: @T, game_id: u64) -> u16;
    fn setting_details(self: @T, settings_id: u32) -> GameSettings;
    fn settings_exists(self: @T, settings_id: u32) -> bool;
    fn game_settings(self: @T, game_id: u64) -> GameSettings;
}

#[dojo::contract]
mod game_systems {
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_tx_info, get_block_timestamp};
    use darkshuffle::constants::{DEFAULT_SETTINGS::GET_DEFAULT_SETTINGS, DEFAULT_NS, SCORE_ATTRIBUTE, SCORE_MODEL, SETTINGS_MODEL, VERSION};
    use darkshuffle::models::{
        card::{Card, CardCategory, CreatureCard, SpellCard, CardRarity, CardType, CardEffect},
        config::{GameSettings, GameSettingsTrait, GameSettingsMetadata, SettingsCounter, CardRarityWeights, MapSettings, BattleSettings, DraftSettings},
        draft::{Draft, DraftOwnerTrait},
        game::{Game, GameActionEvent, GameOwnerTrait, GameState, GameEffects},
        map::{Map, MonsterNode},
        battle::{Battle, BattleOwnerTrait, BattleResources, CreatureDetails, RoundStats, BoardStats},
    };

    use darkshuffle::utils::{
        random,
        achievements::AchievementsUtilsImpl,
        cards::CardUtilsImpl,
        config::ConfigUtilsImpl,
        draft::DraftUtilsImpl,
        renderer::utils::create_metadata,
        battle::BattleUtilsImpl,
        board::BoardUtilsImpl,
        game::GameUtilsImpl,
        hand::HandUtilsImpl,
        map::MapUtilsImpl,
        monsters::MonsterUtilsImpl,
        spell::SpellUtilsImpl,
        summon::SummonUtilsImpl,
    };
    
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin_token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait, IERC721Metadata};
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};

    use tournaments::components::game::game_component;
    use tournaments::components::interfaces::{IGameDetails, IGameToken, ISettings};
    use tournaments::components::libs::lifecycle::{LifecycleAssertionsImpl, LifecycleAssertionsTrait};
    use tournaments::components::models::game::TokenMetadata;
    use tournaments::components::models::lifecycle::Lifecycle;
    
    use achievement::components::achievable::AchievableComponent;
    use achievement::store::{Store, StoreTrait};
    use darkshuffle::utils::tasks::index::{Task, TaskTrait};
    use darkshuffle::utils::trophies::index::{TROPHY_COUNT, Trophy, TrophyTrait};

    component!(path: game_component, storage: game, event: GameEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: AchievableComponent, storage: achievable, event: AchievableEvent);
    
    impl AchievableInternalImpl = AchievableComponent::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl GameImpl = game_component::GameImpl<ContractState>;
    impl GameInternalImpl = game_component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnlyImpl = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        game: game_component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        achievable: AchievableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        GameEvent: game_component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        AchievableEvent: AchievableComponent::Event,
    }

    fn dojo_init(ref self: ContractState, creator_address: ContractAddress) {
        self.erc721.initializer("Dark Shuffle", "DARK", "darkshuffle.dev");
        self
            .game
            .initializer(
                creator_address,
                'Dark Shuffle',
                "Dark Shuffle is a turn-based, collectible card game. Build your deck, battle monsters, and explore a procedurally generated world.",
                'Provable Games',
                'Provable Games',
                'Digital TCG / Deck Building',
                "https://github.com/Provable-Games/dark-shuffle/blob/main/client/public/favicon.svg",
                DEFAULT_NS(),
                SCORE_MODEL(),
                SCORE_ATTRIBUTE(),
                SETTINGS_MODEL(),
            );

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
        world.write_model(@GameSettingsMetadata {
            settings_id: 0,
            name: 'Default',
            description: "Default settings",
            created_by: get_caller_address(),
            created_at: get_block_timestamp(),
        });
        ConfigUtilsImpl::create_genesis_cards(ref world);
    }

    #[abi(embed_v0)]
    impl SettingsImpl of ISettings<ContractState> {
        fn setting_exists(self: @ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings.exists()
        }
    }

    #[abi(embed_v0)]
    impl GameDetailsImpl of IGameDetails<ContractState> {
        fn score(self: @ContractState, game_id: u64) -> u32 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_xp.into()
        }
    }

    #[abi(embed_v0)]
    impl GameSystemsImpl of super::IGameSystems<ContractState> {
        fn start_game(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            let token_metadata: TokenMetadata = world.read_model(game_id);
            self.validate_start_conditions(game_id, @token_metadata);

            let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, game_id);
            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);
            let action_count = 0;

            let mut game = Game {
                game_id,
                state: GameState::Draft.into(),
                hero_health: game_settings.starting_health,
                hero_xp: 1,
                monsters_slain: 0,
                map_level: 0,
                map_depth: 0,
                last_node_id: 0,
                action_count,
            };

            let card_pool = DraftUtilsImpl::get_weighted_draft_list(world, game_settings);
            if game_settings.draft.auto_draft {
                game.state = GameState::Map.into();
                let draft_list = DraftUtilsImpl::auto_draft(seed, card_pool, game_settings.draft.draft_size);
                world.write_model(@Draft { game_id, options: array![].span(), cards: draft_list });
            } else {
                let options = DraftUtilsImpl::get_draft_options(seed, card_pool);
                world.write_model(@Draft { game_id, options, cards: array![].span() });
            }

            world.write_model(@game);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: action_count,
                    },
                );
            game.update_metadata(world);
        }

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

            if current_draft_size == game_settings.draft.draft_size.into() {
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

        fn generate_tree(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            let token_metadata: TokenMetadata = world.read_model(game_id);
            token_metadata.lifecycle.assert_is_playable(game_id, starknet::get_block_timestamp());

            let mut game: Game = world.read_model(game_id);
            game.assert_owner(world);
            game.assert_generate_tree();

            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);

            game.map_level += 1;
            game.map_depth = 1;
            game.last_node_id = 0;
            game.action_count += 1;

            world.write_model(@Map { game_id, level: game.map_level, seed });

            world.write_model(@game);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: game.action_count,
                    },
                );

            // [Achievement] Complete a map
            if game.map_level > 1 {
                let player_id: felt252 = starknet::get_caller_address().into();
                let task_id: felt252 = Task::Explorer.identifier();
                let time = starknet::get_block_timestamp();
                let store = StoreTrait::new(world);
                store.progress(player_id, task_id, count: 1, time: time);
            }
        }

        fn select_node(ref self: ContractState, game_id: u64, node_id: u8) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            let token_metadata: TokenMetadata = world.read_model(game_id);
            token_metadata.lifecycle.assert_is_playable(game_id, starknet::get_block_timestamp());

            let mut game: Game = world.read_model(game_id);
            game.assert_owner(world);
            game.assert_select_node();

            let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, game_id);
            let mut map: Map = world.read_model((game_id, game.map_level));
            assert(MapUtilsImpl::node_available(game, map, node_id, game_settings.map), 'Invalid node');

            game.last_node_id = node_id;

            let monster_node: MonsterNode = MapUtilsImpl::get_monster_node(map, node_id, game_settings.map);
            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);

            MapUtilsImpl::start_battle(ref world, ref game, monster_node, seed);

            game.action_count += 1;

            world.write_model(@game);
            world
                .emit_event(
                    @GameActionEvent {
                        game_id, tx_hash: starknet::get_tx_info().unbox().transaction_hash, count: game.action_count,
                    },
                );
            game.update_metadata(world);
        }

        fn battle_actions(ref self: ContractState, game_id: u64, battle_id: u16, actions: Span<Span<u8>>) {
            assert(*(*actions.at(actions.len() - 1)).at(0) == 1, 'Must end turn');

            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            let token_metadata: TokenMetadata = world.read_model(game_id);
            token_metadata.lifecycle.assert_is_playable(game_id, starknet::get_block_timestamp());

            let mut game: Game = world.read_model(game_id);
            game.assert_owner(world);

            let mut battle: Battle = world.read_model((battle_id, game_id));
            battle.assert_battle();

            let game_settings: GameSettings = ConfigUtilsImpl::get_game_settings(world, battle.game_id);

            let mut battle_resources: BattleResources = world.read_model((battle_id, game_id));
            let mut game_effects: GameEffects = world.read_model(battle.game_id);
            let mut board: Array<CreatureDetails> = BoardUtilsImpl::unpack_board(
                world, game_id, battle_resources.board,
            );
            let mut board_stats: BoardStats = BoardUtilsImpl::get_board_stats(ref board, battle.monster.monster_id);

            let mut round_stats: RoundStats = RoundStats {
                monster_start_health: battle.monster.health, creatures_played: 0, creature_attack_count: 0,
            };

            let mut action_index = 0;
            while action_index < actions.len() {
                let action = *actions.at(action_index);

                match *action.at(0) {
                    0 => {
                        let card_index: u8 = *action.at(1);
                        assert(battle_resources.card_in_hand(card_index), 'Card not in hand');
                        let card: Card = CardUtilsImpl::get_card(world, game_id, card_index);
                        BattleUtilsImpl::deduct_energy_cost(ref battle, card);

                        let card_category: CardCategory = card.category.into();
                        match card_category {
                            CardCategory::Creature => {
                                let creature_card: CreatureCard = CardUtilsImpl::get_creature_card(world, card.id);
                                SummonUtilsImpl::summon_creature(
                                    card_index,
                                    creature_card,
                                    ref battle,
                                    ref board,
                                    ref board_stats,
                                    ref round_stats,
                                    game_effects,
                                );
                                AchievementsUtilsImpl::play_creature(ref world, creature_card);
                            },
                            CardCategory::Spell => {
                                let spell_card: SpellCard = CardUtilsImpl::get_spell_card(world, card.id);
                                SpellUtilsImpl::cast_spell(spell_card, ref battle, ref board, board_stats);
                            },
                            _ => {},
                        }

                        HandUtilsImpl::remove_hand_card(ref battle_resources, *action.at(1));
                    },
                    1 => {
                        assert(action_index == actions.len() - 1, 'Invalid action');
                        BoardUtilsImpl::attack_monster(ref battle, ref board, board_stats, ref round_stats);
                        BoardUtilsImpl::remove_dead_creatures(ref battle, ref board, board_stats);
                        board_stats = BoardUtilsImpl::get_board_stats(ref board, battle.monster.monster_id);

                        if battle.monster.health + 25 <= round_stats.monster_start_health {
                            AchievementsUtilsImpl::big_hit(ref world);
                        }
                    },
                    _ => { assert(false, 'Invalid action'); },
                }

                if GameUtilsImpl::is_battle_over(battle) {
                    break;
                }

                action_index += 1;
            };

            world
                .emit_event(
                    @GameActionEvent {
                        game_id,
                        tx_hash: starknet::get_tx_info().unbox().transaction_hash,
                        count: game.action_count + battle.round.into(),
                    },
                );

            let random_hash = random::get_random_hash();
            let seed: u128 = random::get_entropy(random_hash);

            if GameUtilsImpl::is_battle_over(battle) {
                GameUtilsImpl::end_battle(ref world, ref battle, ref game_effects, game_settings);
                return;
            }

            if game_effects.hero_card_heal {
                BattleUtilsImpl::heal_hero(ref battle, battle_resources.hand.len().try_into().unwrap());
            }

            MonsterUtilsImpl::monster_ability(
                ref battle, ref battle_resources, game_effects, ref board, round_stats, seed,
            );
            BoardUtilsImpl::remove_dead_creatures(ref battle, ref board, board_stats);

            if battle.monster.health > 0 {
                BattleUtilsImpl::damage_hero(ref battle, game_effects, battle.monster.attack);
            }

            if GameUtilsImpl::is_battle_over(battle) {
                GameUtilsImpl::end_battle(ref world, ref battle, ref game_effects, game_settings);
            } else {
                battle_resources.board = BoardUtilsImpl::get_packed_board(ref board);
                
                let energy = game_settings.battle.start_energy + battle.round;
                battle.hero.energy = if energy > game_settings.battle.max_energy {
                    game_settings.battle.max_energy
                } else {
                    energy
                };

                battle.round += 1;
                HandUtilsImpl::draw_cards(
                    ref battle_resources,
                    game_settings.battle.draw_amount + game_effects.card_draw,
                    game_settings.battle.max_hand_size,
                    seed,
                );

                world.write_model(@battle);
                world.write_model(@battle_resources);
            }

            game.update_metadata(world);
        }

        fn add_settings(
            ref self: ContractState,
            name: felt252,
            description: ByteArray,
            starting_health: u8,
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
            possible_branches: u8,
            level_depth: u8,
            enemy_attack_min: u8,
            enemy_attack_max: u8,
            enemy_health_min: u8,
            enemy_health_max: u8,
            enemy_attack_scaling: u8,
            enemy_health_scaling: u8,
        ) -> u32 {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());

            // increment settings counter
            let mut settings_count: SettingsCounter = world.read_model(VERSION);
            settings_count.count += 1;

            let settings: GameSettings = GameSettings {
                settings_id: settings_count.count,
                starting_health,
                persistent_health,
                map: MapSettings {
                    possible_branches,
                    level_depth,
                    enemy_attack_min,
                    enemy_attack_max,
                    enemy_health_min,
                    enemy_health_max,
                    enemy_attack_scaling,
                    enemy_health_scaling,
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
            world.write_model(@GameSettingsMetadata {
                settings_id: settings_count.count,
                name,
                description,
                created_by: get_caller_address(),
                created_at: get_block_timestamp(),
            });

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
            world.write_model(@GameSettingsMetadata {
                settings_id: settings_count.count,
                name: 'Random',
                description: "Random settings",
                created_by: get_caller_address(),
                created_at: get_block_timestamp(),
            });

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

        fn player_name(self: @ContractState, game_id: u64) -> felt252 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let token_metadata: TokenMetadata = world.read_model(game_id);
            token_metadata.player_name
        }

        fn health(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_health
        }

        fn game_state(self: @ContractState, game_id: u64) -> GameState {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.state.into()
        }

        fn xp(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.hero_xp
        }

        fn cards(self: @ContractState, game_id: u64) -> Span<felt252> {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let draft: Draft = world.read_model(game_id);
            let mut cards = array![];

            let mut i = 0;
            while i < draft.cards.len() {
                let card: Card = CardUtilsImpl::get_card(world, game_id, *draft.cards.at(i));
                cards.append(card.name);
                i += 1;
            };

            cards.span()
        }

        fn monsters_slain(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.monsters_slain
        }

        fn level(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.map_level
        }

        fn map_depth(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.map_depth
        }

        fn last_node_id(self: @ContractState, game_id: u64) -> u8 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.last_node_id
        }

        fn action_count(self: @ContractState, game_id: u64) -> u16 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            game.action_count
        }
    }

    #[abi(embed_v0)]
    impl ERC721Metadata of IERC721Metadata<ContractState> {
        /// Returns the NFT name.
        fn name(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_name.read()
        }

        /// Returns the NFT symbol.
        fn symbol(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_symbol.read()
        }

        /// Returns the Uniform Resource Identifier (URI) for the `token_id` token.
        /// If the URI is not set, the return value will be an empty ByteArray.
        ///
        /// Requirements:
        ///
        /// - `token_id` exists.
        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self.erc721._require_owned(token_id);

            let token_id_u64 = token_id.try_into().unwrap();

            let hero_name = self.player_name(token_id_u64);
            let hero_health = self.health(token_id_u64);
            let hero_xp = self.xp(token_id_u64);
            let game_state = self.game_state(token_id_u64);
            let cards = self.cards(token_id_u64);

            create_metadata(token_id_u64, hero_name, hero_health, hero_xp, game_state.into(), cards)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn validate_start_conditions(self: @ContractState, token_id: u64, token_metadata: @TokenMetadata) {
            self.assert_token_ownership(token_id);
            self.assert_game_not_started(token_id);
            token_metadata.lifecycle.assert_is_playable(token_id, starknet::get_block_timestamp());
        }

        #[inline(always)]
        fn assert_token_ownership(self: @ContractState, token_id: u64) {
            let token_owner = ERC721Impl::owner_of(self, token_id.into());
            assert!(
                token_owner == starknet::get_caller_address(),
                "Dark Shuffle: Caller is not owner of token {}",
                token_id,
            );
        }

        #[inline(always)]
        fn assert_game_not_started(self: @ContractState, game_id: u64) {
            let game: Game = self.world(@DEFAULT_NS()).read_model(game_id);
            assert!(game.hero_xp == 0, "Dark Shuffle: Game {} has already started", game_id);
        }

        #[inline(always)]
        fn validate_settings(self: @ContractState, settings: GameSettings) {
            assert!(settings.starting_health > 0, "Starting health must be greater than 0");
            assert!(settings.starting_health <= 200, "Maximum starting health cannot be greater than 200");

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

            assert!(settings.map.possible_branches > 0, "Maximum branches must be greater than 0");
            assert!(settings.map.possible_branches <= 3, "Maximum branches cannot be greater than 3");

            assert!(settings.map.level_depth > 0, "Level depth must be greater than 0");
            assert!(settings.map.level_depth <= 5, "Level depth cannot be greater than 5");

            assert!(settings.map.enemy_attack_min > 0, "Enemy attack minimum must be greater than 0");
            assert!(settings.map.enemy_attack_min <= 10, "Enemy attack minimum cannot be greater than 10");
            assert!(settings.map.enemy_attack_max >= settings.map.enemy_attack_min, "Enemy attack cannot be less than minimum");
            assert!(settings.map.enemy_attack_max <= 10, "Enemy attack maximum cannot be greater than 10");
            
            assert!(settings.map.enemy_health_min >= 10, "Enemy health minimum cannot be less than 10");
            assert!(settings.map.enemy_health_min <= 200, "Enemy health minimum cannot be greater than 200");
            assert!(settings.map.enemy_health_max >= settings.map.enemy_health_min, "Enemy health cannot be less than minimum");
            assert!(settings.map.enemy_health_max <= 200, "Enemy health maximum cannot be greater than 200");
            
            assert!(settings.map.enemy_attack_scaling <= 10, "Enemy attack scaling cannot be greater than 10");
            assert!(settings.map.enemy_health_scaling <= 50, "Enemy health scaling cannot be greater than 50");
        }
    }
}
