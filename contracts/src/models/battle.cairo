use darkshuffle::models::card::Card;
use darkshuffle::models::game::{Game, GameOwnerTrait};
use darkshuffle::models::map::MonsterNode;
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, get_caller_address};

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct Battle {
    #[key]
    battle_id: u16,
    #[key]
    game_id: u64,
    round: u8,
    hero: Hero,
    monster: Monster,
    battle_effects: BattleEffects
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct BattleResources {
    #[key]
    battle_id: u16,
    #[key]
    game_id: u64,
    hand: Span<u8>,
    deck: Span<u8>,
    board: Span<Creature>,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct Hero {
    health: u8,
    energy: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct Monster {
    attack: u8,
    health: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct Creature {
    card_id: u8,
    attack: u8,
    health: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct BattleEffects {
    enemy_marks: u8,
    hero_dmg_reduction: u8,
    next_hunter_attack_bonus: u8,
    next_hunter_health_bonus: u8,
    next_brute_attack_bonus: u8,
    next_brute_health_bonus: u8,
    next_magical_attack_bonus: u8,
    next_magical_health_bonus: u8,
}

#[derive(Copy, Drop, Serde)]
pub struct CreatureDetails {
    card: Card,
    card_id: u8,
    attack: u8,
    health: u8,
}

#[derive(Copy, Drop, Serde)]
pub struct BoardStats {
    monster: MonsterNode,
    magical_count: u8,
    brute_count: u8,
    hunter_count: u8,
}

#[derive(Copy, Drop, Serde)]
pub struct RoundStats {
    monster_start_health: u8,
    creatures_played: u8,
    creature_attack_count: u8,
}

#[generate_trait]
impl BattleOwnerImpl of BattleOwnerTrait {
    fn assert_battle(self: Battle) {
        assert(self.hero.health > 0, 'Battle over');
        assert(self.monster.health > 0, 'Battle over');
    }

    fn card_in_hand(self: BattleResources, card_id: u8) -> bool {
        let mut is_in_hand = false;

        let mut i = 0;
        while i < self.hand.len() {
            if *self.hand.at(i) == card_id {
                is_in_hand = true;
                break;
            }

            i += 1;
        };

        is_in_hand
    }
}
