use darkshuffle::utils::trophies::interface::{BushidoTask, Task, TaskTrait, TrophyTrait};

impl BruteSquad of TrophyTrait {
    #[inline]
    fn identifier(level: u8) -> felt252 {
        match level {
            0 => 'BRUTE_SQUAD_I',
            1 => 'BRUTE_SQUAD_II',
            2 => 'BRUTE_SQUAD_III',
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
        'Brute Squad'
    }

    #[inline]
    fn icon(level: u8) -> felt252 {
        'fa-hand-fist'
    }

    #[inline]
    fn title(level: u8) -> felt252 {
        match level {
            0 => 'Brute Squad I',
            1 => 'Brute Squad II',
            2 => 'Brute Squad III',
            _ => '',
        }
    }

    #[inline]
    fn description(level: u8) -> ByteArray {
        "Who needs strategy when you've got muscle?"
    }

    #[inline]
    fn tasks(level: u8) -> Span<BushidoTask> {
        let count: u32 = match level {
            0 => 20,
            1 => 50,
            2 => 100,
            _ => 0,
        };
        Task::BruteSquad.tasks(count)
    }
}
