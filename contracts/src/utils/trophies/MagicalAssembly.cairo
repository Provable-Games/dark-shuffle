use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl MagicalAssembly of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        match level {
            0 => 'MAGICAL_ASSEMBLY_I',
            1 => 'MAGICAL_ASSEMBLY_II',
            2 => 'MAGICAL_ASSEMBLY_III',
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
        'Magical Assembly'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-wand-magic-sparkles'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        match level {
            0 => 'Magical Assembly I',
            1 => 'Magical Assembly II',
            2 => 'Magical Assembly III',
            _ => '',
        }
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "The arcane alliance grows stronger"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = match level {
            0 => 20,
            1 => 50,
            2 => 100,
            _ => 0,
        };
        Task::MagicalAssembly.tasks(count)
    }
}
