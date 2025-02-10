use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl Seasoned of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        match level {
            0 => 'SEASONED_I',
            1 => 'SEASONED_II',
            2 => 'SEASONED_III',
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
            0 => 20,
            1 => 30,
            2 => 50,
            _ => 0,
        }
    }

    #[inline]
    fn group() -> felt252 {
        'Seasoned'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-helmet-battle'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        match level {
            0 => 'Seasoned I',
            1 => 'Seasoned II',
            2 => 'Seasoned III',
            _ => '',
        }
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "A different kind of spice"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = match level {
            0 => 2,
            1 => 5,
            2 => 10,
            _ => 0,
        };
        Task::Seasoned.tasks(count)
    }
}
