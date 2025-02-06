use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl HuntersProwess of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        match level {
            0 => 'HUNTERS_PROWESS_I',
            1 => 'HUNTERS_PROWESS_II',
            2 => 'HUNTERS_PROWESS_III',
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
        'Hunters Prowess'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-rabbit-running'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        match level {
            0 => 'Hunters Prowess I',
            1 => 'Hunters Prowess II',
            2 => 'Hunters Prowess III',
            _ => '',
        }
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "Stalking your prey"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = match level {
            0 => 10,
            1 => 50,
            2 => 100,
            _ => 0,
        };
        Task::HuntersProwess.tasks(count)
    }
}
