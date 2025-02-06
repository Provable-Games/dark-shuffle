use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl BruteForce of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        match level {
            0 => 'BRUTE_FORCE_I',
            1 => 'BRUTE_FORCE_II',
            2 => 'BRUTE_FORCE_III',
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
            2 => 90,
            _ => 0,
        }
    }

    #[inline]
    fn group() -> felt252 {
        'Brute Force'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-hydra'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        match level {
            0 => 'Brute Force I',
            1 => 'Brute Force II',
            2 => 'Brute Force III',
            _ => '',
        }
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "Power over finesse"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = match level {
            0 => 10,
            1 => 50,
            2 => 100,
            _ => 0,
        };
        Task::BruteForce.tasks(count)
    }
}
