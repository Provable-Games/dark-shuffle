use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl Explorer of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        match level {
            0 => 'EXPLORER_I',
            1 => 'EXPLORER_II',
            2 => 'EXPLORER_III',
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
            0 => 10,
            1 => 20,
            2 => 30,
            _ => 0,
        }
    }

    #[inline]
    fn group() -> felt252 {
        'Explorer'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        match level {
            0 => 'fa-mountain',
            1 => 'fa-mountains',
            2 => 'fa-mountain-sun',
            _ => '',
        }
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        match level {
            0 => 'Explorer I',
            1 => 'Explorer II',
            2 => 'Explorer III',
            _ => '',
        }
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "What lies in the darkness?"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = match level {
            0 => 5,
            1 => 15,
            2 => 30,
            _ => 0,
        };
        Task::Explorer.tasks(count)
    }
}
