// External imports

use achievement::types::task::{Task as BushidoTask, TaskTrait as BushidoTaskTrait};

// Internal imports

use darkshuffle::utils::tasks;

// Types

#[derive(Copy, Drop)]
enum Task {
    None,
    BigHit,
    BruteForce,
    BruteSquad,
    Explorer,
    Heroic,
    HuntersGathering,
    HuntersProwess,
    Legend,
    MagicalAssembly,
    MagicalMayhem,
    Seasoned,
    Survivor,
}

// Implementations

#[generate_trait]
impl TaskImpl of TaskTrait {
    #[inline]
    fn identifier(self: Task) -> felt252 {
        match self {
            Task::None => 0,
            Task::BigHit => tasks::BigHit::BigHit::identifier(),
            Task::BruteForce => tasks::BruteForce::BruteForce::identifier(),
            Task::BruteSquad => tasks::BruteSquad::BruteSquad::identifier(),
            Task::Explorer => tasks::Explorer::Explorer::identifier(),
            Task::Heroic => tasks::Heroic::Heroic::identifier(),
            Task::HuntersGathering => tasks::HuntersGathering::HuntersGathering::identifier(),
            Task::HuntersProwess => tasks::HuntersProwess::HuntersProwess::identifier(),
            Task::Legend => tasks::Legend::Legend::identifier(),
            Task::MagicalAssembly => tasks::MagicalAssembly::MagicalAssembly::identifier(),
            Task::MagicalMayhem => tasks::MagicalMayhem::MagicalMayhem::identifier(),
            Task::Seasoned => tasks::Seasoned::Seasoned::identifier(),
            Task::Survivor => tasks::Survivor::Survivor::identifier(),
        }
    }

    #[inline]
    fn description(self: Task, count: u32) -> ByteArray {
        match self {
            Task::None => "",
            Task::BigHit => tasks::BigHit::BigHit::description(count),
            Task::BruteForce => tasks::BruteForce::BruteForce::description(count),
            Task::BruteSquad => tasks::BruteSquad::BruteSquad::description(count),
            Task::Explorer => tasks::Explorer::Explorer::description(count),
            Task::Heroic => tasks::Heroic::Heroic::description(count),
            Task::HuntersGathering => tasks::HuntersGathering::HuntersGathering::description(count),
            Task::HuntersProwess => tasks::HuntersProwess::HuntersProwess::description(count),
            Task::Legend => tasks::Legend::Legend::description(count),
            Task::MagicalAssembly => tasks::MagicalAssembly::MagicalAssembly::description(count),
            Task::MagicalMayhem => tasks::MagicalMayhem::MagicalMayhem::description(count),
            Task::Seasoned => tasks::Seasoned::Seasoned::description(count),
            Task::Survivor => tasks::Survivor::Survivor::description(count),
        }
    }

    #[inline]
    fn tasks(self: Task, count: u32) -> Span<BushidoTask> {
        let task_id: felt252 = self.identifier();
        let description: ByteArray = self.description(count);
        array![BushidoTaskTrait::new(task_id, count.into(), description)].span()
    }
}

impl IntoTaskU8 of core::Into<Task, u8> {
    #[inline]
    fn into(self: Task) -> u8 {
        match self {
            Task::None => 0,
            Task::BigHit => 1,
            Task::BruteForce => 2,
            Task::BruteSquad => 3,
            Task::Explorer => 4,
            Task::Heroic => 5,
            Task::HuntersGathering => 6,
            Task::HuntersProwess => 7,
            Task::Legend => 8,
            Task::MagicalAssembly => 9,
            Task::MagicalMayhem => 10,
            Task::Seasoned => 11,
            Task::Survivor => 12,
        }
    }
}

impl IntoU8Task of core::Into<u8, Task> {
    #[inline]
    fn into(self: u8) -> Task {
        let card: felt252 = self.into();
        match card {
            0 => Task::None,
            1 => Task::BigHit,
            2 => Task::BruteForce,
            3 => Task::BruteSquad,
            4 => Task::Explorer,
            5 => Task::Heroic,
            6 => Task::HuntersGathering,
            7 => Task::HuntersProwess,
            8 => Task::Legend,
            9 => Task::MagicalAssembly,
            10 => Task::MagicalMayhem,
            11 => Task::Seasoned,
            12 => Task::Survivor,
            _ => Task::None,
        }
    }
}

impl TaskPrint of core::debug::PrintTrait<Task> {
    #[inline]
    fn print(self: Task) {
        self.identifier().print();
    }
}

