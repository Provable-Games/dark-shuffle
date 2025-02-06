use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl MagicalMayhem of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        match level {
            0 => 'MAGICAL_MAYHEM_I',
            1 => 'MAGICAL_MAYHEM_II',
            2 => 'MAGICAL_MAYHEM_III',
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
        'Magical Mayhem'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-cauldron'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        match level {
            0 => 'Magical Mayhem I',
            1 => 'Magical Mayhem II',
            2 => 'Magical Mayhem III',
            _ => '',
        }
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "Let the spells fly"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = match level {
            0 => 10,
            1 => 50,
            2 => 100,
            _ => 0,
        };
        Task::MagicalMayhem.tasks(count)
    }
}
