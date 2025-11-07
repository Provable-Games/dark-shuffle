use darkshuffle::models::card::{CardType, CreatureCard};

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct Battle {
    #[key]
    pub battle_id: u16,
    #[key]
    pub game_id: u64,
    pub round: u8,
    pub hero: Hero,
    pub monster: Monster,
    pub battle_effects: BattleEffects,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct BattleResources {
    #[key]
    pub battle_id: u16,
    #[key]
    pub game_id: u64,
    pub hand: Span<u8>,
    pub deck: Span<u8>,
    pub board: Span<Creature>,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct Hero {
    pub health: u8,
    pub energy: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct Monster {
    pub monster_id: u8,
    pub attack: u8,
    pub health: u16,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct Creature {
    pub card_index: u8,
    pub attack: u8,
    pub health: u8,
}

#[derive(IntrospectPacked, Copy, Drop, Serde)]
pub struct BattleEffects {
    pub enemy_marks: u8,
    pub hero_dmg_reduction: u8,
    pub next_hunter_attack_bonus: u8,
    pub next_hunter_health_bonus: u8,
    pub next_brute_attack_bonus: u8,
    pub next_brute_health_bonus: u8,
    pub next_magical_attack_bonus: u8,
    pub next_magical_health_bonus: u8,
}

#[derive(Copy, Drop, Serde)]
pub struct CreatureDetails {
    pub card_index: u8,
    pub attack: u8,
    pub health: u8,
    pub creature_card: CreatureCard,
}

#[derive(Copy, Drop, Serde)]
pub struct BoardStats {
    pub magical_count: u8,
    pub brute_count: u8,
    pub hunter_count: u8,
    pub monster_type: CardType,
}

#[derive(Copy, Drop, Serde)]
pub struct RoundStats {
    pub monster_start_health: u16,
    pub creatures_played: u8,
    pub creature_attack_count: u8,
}

#[generate_trait]
pub impl BattleOwnerImpl of BattleOwnerTrait {
    fn assert_battle(self: Battle) {
        assert(self.hero.health > 0, 'Battle over');
        assert(self.monster.health > 0, 'Battle over');
    }

    fn card_in_hand(self: BattleResources, card_index: u8) -> bool {
        let mut is_in_hand = false;

        let mut i = 0;
        while i < self.hand.len() {
            if *self.hand.at(i) == card_index {
                is_in_hand = true;
                break;
            }

            i += 1;
        };

        is_in_hand
    }
}
