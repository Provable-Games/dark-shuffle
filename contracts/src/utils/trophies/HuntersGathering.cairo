use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl HuntersGathering of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        match level {
            0 => 'HUNTERS_GATHERING_I',
            1 => 'HUNTERS_GATHERING_II',
            2 => 'HUNTERS_GATHERING_III',
            _ => '',
        }
    }

    #[inline]
    fn hidden(level: u8) -> bool {
        false
    }

    #[inline]
    fn index(level: u8) -> u8 {
        level
    }

    #[inline]
    fn points(level: u8) -> u16 {
        match level {
            0 => 30,
            1 => 50,
            2 => 80,
            _ => 0,
        }
    }

    #[inline]
    fn group() -> felt252 {
        'Hunters Gathering'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-paw-claws'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        match level {
            0 => 'Hunters Gathering I',
            1 => 'Hunters Gathering II',
            2 => 'Hunters Gathering III',
            _ => '',
        }
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "All your prey belong to us"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = match level {
            0 => 20,
            1 => 50,
            2 => 100,
            _ => 0,
        };
        Task::HuntersGathering.tasks(count)
    }
}
