use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl BigHit of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        'BIG_HIT'
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
        'Big Hit'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-scythe'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        'Big Hit'
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "Now that's what I call overkill"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = 1;
        Task::BigHit.tasks(count)
    }
}
