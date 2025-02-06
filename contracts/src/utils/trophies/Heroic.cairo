use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl Heroic of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        'HEROIC'
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
        'Heroic'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-khanda'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        'Heroic'
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "You've surpassed your limits"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = 1;
        Task::Heroic.tasks(count)
    }
}
