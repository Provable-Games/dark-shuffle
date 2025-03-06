#[starknet::interface]
trait IBattleSystems<T> {
    fn battle_actions(ref self: T, game_id: u64, battle_id: u16, actions: Span<Span<u8>>);
}

#[dojo::contract]
mod battle_systems {
    use achievement::store::{Store, StoreTrait};

    use darkshuffle::constants::{DEFAULT_NS};
    use darkshuffle::models::battle::{
        Battle, BattleOwnerTrait, Creature, CreatureDetails, BoardStats, RoundStats, BattleResources
    };
    use darkshuffle::models::map::{Map, MonsterNode};
    use darkshuffle::models::card::{Card, CardDetails};
    use darkshuffle::models::config::GameSettings;
    use darkshuffle::models::game::{Game, GameEffects, GameActionEvent, GameOwnerTrait};
    use darkshuffle::utils::{
        achievements::AchievementsUtilsImpl, battle::BattleUtilsImpl, board::BoardUtilsImpl, cards::CardUtilsImpl,
        config::ConfigUtilsImpl, game::GameUtilsImpl, hand::HandUtilsImpl, monsters::MonsterUtilsImpl, random,
        map::MapUtilsImpl, spell::SpellUtilsImpl, summon::SummonUtilsImpl,
    };
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use tournaments::components::libs::lifecycle::{LifecycleAssertionsImpl, LifecycleAssertionsTrait};
    use tournaments::components::models::game::TokenMetadata;
    use tournaments::components::models::lifecycle::Lifecycle;

    #[abi(embed_v0)]
    impl BattleSystemsImpl of super::IBattleSystems<ContractState> {
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
                world, game_id, battle_resources.board
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
                        assert(battle_resources.card_in_hand(*action.at(1)), 'Card not in hand');
                        let card: Card = CardUtilsImpl::get_card(world, game_id, *action.at(1));
                        BattleUtilsImpl::deduct_energy_cost(ref battle, round_stats, game_effects, card);

                        match card.card_details {
                            CardDetails::creature_card(creature_details) => {
                                SummonUtilsImpl::summon_creature(
                                    card,
                                    *action.at(1),
                                    creature_details,
                                    ref battle,
                                    ref board,
                                    ref board_stats,
                                    ref round_stats,
                                    game_effects
                                );
                                AchievementsUtilsImpl::play_creature(ref world, card);
                            },
                            CardDetails::spell_card(spell_details) => {
                                SpellUtilsImpl::cast_spell(card, spell_details, ref battle, ref board, board_stats);
                            }
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
                GameUtilsImpl::end_battle(ref world, ref battle, ref game_effects);
                return;
            };

            if game_effects.hero_card_heal {
                BattleUtilsImpl::heal_hero(ref battle, battle_resources.hand.len().try_into().unwrap());
            }

            MonsterUtilsImpl::monster_ability(
                ref battle, ref battle_resources, game_effects, ref board, round_stats, seed
            );
            BoardUtilsImpl::remove_dead_creatures(ref battle, ref board, board_stats);

            if battle.monster.health > 0 {
                BattleUtilsImpl::damage_hero(ref battle, game_effects, battle.monster.attack);
            }

            if GameUtilsImpl::is_battle_over(battle) {
                GameUtilsImpl::end_battle(ref world, ref battle, ref game_effects);
            } else {
                battle_resources.board = BoardUtilsImpl::get_packed_board(ref board);
                battle.round += 1;

                if battle.round > game_settings.max_energy {
                    battle.hero.energy = game_settings.max_energy;
                } else {
                    battle.hero.energy = battle.round;
                }

                HandUtilsImpl::draw_cards(
                    ref battle_resources, 1 + game_effects.card_draw, game_settings.max_hand_size, seed
                );

                world.write_model(@battle);
                world.write_model(@battle_resources);
            }

            game.update_metadata(world);
        }
    }
}
