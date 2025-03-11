use darkshuffle::models::battle::BattleResources;
use darkshuffle::utils::random;

#[generate_trait]
impl HandUtilsImpl of HandUtilsTrait {
    fn remove_hand_card(ref battle_resources: BattleResources, card_index: u8) {
        let mut card_removed = false;
        let mut new_hand = array![];

        let mut i = 0;
        while i < battle_resources.hand.len() {
            if *battle_resources.hand.at(i) == card_index && !card_removed {
                card_removed = true;
            } else {
                new_hand.append(*battle_resources.hand.at(i));
            }

            i += 1;
        };

        battle_resources.hand = new_hand.span();
    }

    fn draw_cards(ref battle_resources: BattleResources, amount: u8, max_hand_size: u8, seed: u128) {
        if battle_resources.deck.len() == 0 || battle_resources.hand.len() >= max_hand_size.into() {
            return;
        }

        let mut new_hand = array![];
        let mut new_deck = battle_resources.deck;
        let mut seed = seed;

        let mut i = 0;
        while i < battle_resources.hand.len() {
            new_hand.append(*battle_resources.hand.at(i));
            i += 1;
        };

        i = 0;
        while i < amount.into() {
            if new_hand.len() >= max_hand_size.into() {
                break;
            }

            seed = random::LCG(seed);
            let random_deck_card = random::get_random_number_zero_indexed(seed, new_deck.len().try_into().unwrap());
            new_hand.append(*new_deck.at(random_deck_card.into()));
            new_deck = Self::remove_card_from_deck(new_deck, random_deck_card);
            i += 1;
        };

        battle_resources.hand = new_hand.span();
        battle_resources.deck = new_deck;
    }

    fn remove_card_from_deck(deck: Span<u8>, index: u8) -> Span<u8> {
        let mut new_deck = array![];

        let mut i = 0;
        while i < deck.len() {
            if i != index.into() {
                new_deck.append(*deck.at(i));
            }

            i += 1;
        };

        new_deck.span()
    }
}
