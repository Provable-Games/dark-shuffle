use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl Legend of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        'LEGEND'
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
        90
    }

    #[inline]
    fn group() -> felt252 {
        'Legend'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-medal'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        'Legend'
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "Your name etched in history"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = 1;
        Task::Legend.tasks(count)
    }
}
