use darkshuffle::models::game::{Game, GameOwnerTrait};
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, get_caller_address};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Battle {
    #[key]
    battle_id: u16,
    #[key]
    game_id: u64,
    round: u8,
    hero: Hero,
    monster: Monster,
    hand: Span<u8>,
    deck: Span<u8>,
    battle_effects: BattleEffects,
}

#[derive(Introspect, Copy, Drop, Serde)]
#[dojo::model]
pub struct Board {
    #[key]
    battle_id: u16,
    #[key]
    game_id: u64,
    creature1: Creature,
    creature2: Creature,
    creature3: Creature,
    creature4: Creature,
    creature5: Creature,
    creature6: Creature,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct Hero {
    health: u8,
    energy: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct Monster {
    monster_id: u8, // TODO: could be moved to fixed model
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
}

#[derive(Copy, Drop, Serde)]
pub struct BoardStats {
    magical_count: u8,
    brute_count: u8,
    hunter_count: u8,
    monster_type: CreatureType,
}

#[derive(Copy, Drop, Serde)]
pub struct RoundStats {
    monster_start_health: u8,
    creatures_played: u8,
    creature_attack_count: u8,
}

#[derive(Copy, Drop)]
pub struct Card {
    card_id: u8,
    name: felt252,
    card_type: CardType,
    card_tier: CardTier,
    creature_type: CreatureType,
    cost: u8,
    attack: u8,
    health: u8,
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum CardType {
    Creature,
    Spell,
}

#[derive(PartialEq, Introspect, Copy, Drop, Serde)]
pub enum CreatureType {
    Hunter,
    Brute,
    Magical,
    Spell,
    All,
    None,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub enum CardTier {
    T1,
    T2,
    T3,
    T4,
    T5,
}

#[generate_trait]
impl BattleOwnerImpl of BattleOwnerTrait {
    fn assert_battle(self: Battle, world: WorldStorage) {
        let game: Game = world.read_model(self.game_id);
        game.assert_owner(world);

        assert(self.hero.health > 0, 'Battle over');
        assert(self.monster.health > 0, 'Battle over');
    }

    fn card_in_hand(self: Battle, card_id: u8) -> bool {
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

    fn assert_creature(self: Creature) {
        assert(self.card_id != 0, 'Creature not found');
        assert(self.health > 0, 'Creature dead');
    }
}
