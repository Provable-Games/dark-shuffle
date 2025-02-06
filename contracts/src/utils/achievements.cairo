use achievement::store::{Store, StoreTrait};
use darkshuffle::models::battle::{Card, CreatureType};
use darkshuffle::utils::cards::CardUtilsImpl;
use darkshuffle::utils::tasks::index::{Task, TaskTrait};
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use starknet::{get_block_timestamp, get_caller_address};

#[generate_trait]
impl AchievementsUtilsImpl of AchievementsUtilsTrait {
    fn play_creature(ref world: WorldStorage, card: Card) {
        let store = StoreTrait::new(world);
        let player_id: felt252 = get_caller_address().into();
        let time = get_block_timestamp();

        match card.creature_type {
            CreatureType::Hunter => {
                let task_id: felt252 = Task::HuntersGathering.identifier();
                store.progress(player_id, task_id, count: 1, time: time);
            },
            CreatureType::Brute => {
                let task_id: felt252 = Task::BruteSquad.identifier();
                store.progress(player_id, task_id, count: 1, time: time);
            },
            CreatureType::Magical => {
                let task_id: felt252 = Task::MagicalAssembly.identifier();
                store.progress(player_id, task_id, count: 1, time: time);
            },
            _ => {},
        }
    }

    fn defeat_enemy(ref world: WorldStorage, monster_id: u8) {
        let store = StoreTrait::new(world);
        let player_id: felt252 = get_caller_address().into();
        let time = get_block_timestamp();

        let monster_type: CreatureType = CardUtilsImpl::get_card(monster_id).creature_type;
        match monster_type {
            CreatureType::Hunter => {
                let task_id: felt252 = Task::HuntersProwess.identifier();
                store.progress(player_id, task_id, count: 1, time: time);
            },
            CreatureType::Brute => {
                let task_id: felt252 = Task::BruteForce.identifier();
                store.progress(player_id, task_id, count: 1, time: time);
            },
            CreatureType::Magical => {
                let task_id: felt252 = Task::MagicalMayhem.identifier();
                store.progress(player_id, task_id, count: 1, time: time);
            },
            _ => {},
        }
    }

    fn survivor(ref world: WorldStorage) {
        let store = StoreTrait::new(world);
        let player_id: felt252 = get_caller_address().into();
        let time = get_block_timestamp();

        let task_id: felt252 = Task::Survivor.identifier();
        store.progress(player_id, task_id, count: 1, time: time);
    }

    fn big_hit(ref world: WorldStorage) {
        let store = StoreTrait::new(world);
        let player_id: felt252 = get_caller_address().into();
        let time = get_block_timestamp();

        let task_id: felt252 = Task::BigHit.identifier();
        store.progress(player_id, task_id, count: 1, time: time);
    }

    fn heroic(ref world: WorldStorage) {
        let store = StoreTrait::new(world);
        let player_id: felt252 = get_caller_address().into();
        let time = get_block_timestamp();

        let task_id: felt252 = Task::Heroic.identifier();
        store.progress(player_id, task_id, count: 1, time: time);
    }
}
