use darkshuffle::models::battle::BattleResources;
use darkshuffle::utils::random;

#[generate_trait]
impl HandUtilsImpl of HandUtilsTrait {
    /// Removes the first occurrence of a specific card from the player's hand.
    ///
    /// This function iterates through the `hand` span within the provided `battle_resources`.
    /// It finds the first element that matches the `card_index` and removes it,
    /// reconstructing the hand without that card. If the hand contains multiple instances
    /// of the same card index, only the first one encountered is removed.
    ///
    /// # Arguments
    ///
    /// * `ref battle_resources` - A mutable reference to the `BattleResources` struct,
    ///                           which contains the `hand` span to be modified.
    /// * `card_index` - The `u8` identifier of the card to remove from the hand.
    ///
    /// # Panics
    ///
    /// * Panics with the message "Hand is empty" if the `battle_resources.hand` span
    ///   is empty when the function is called.
    /// * Panics with the message "Card not found in hand" if the specified `card_index`
    ///   is not found within the `battle_resources.hand` span after iterating through it.
    fn remove_hand_card(ref battle_resources: BattleResources, card_index: u8) {
        assert!(battle_resources.hand.len() > 0, "Hand is empty");

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

        assert!(card_removed, "Card not found in hand");

        battle_resources.hand = new_hand.span();
    }

    /// Draws a specified number of cards randomly from the deck into the hand,
    /// respecting hand size limits and deck availability.
    ///
    /// This function simulates drawing cards in a card game. It takes a specified
    /// `amount` of cards to draw, the `max_hand_size` allowed, and a `seed` for
    /// pseudo-random number generation (using LCG). Cards are drawn one by one
    /// from a random position in the deck (`new_deck`, initially a copy of
    /// `battle_resources.deck`) and appended to the hand (`new_hand`, initially
    /// a copy of `battle_resources.hand`). The drawn card is removed from the
    /// `new_deck` using `remove_card_from_deck`.
    ///
    /// Drawing stops if:
    /// 1. The specified `amount` of cards has been drawn.
    /// 2. The hand size (`new_hand.len()`) reaches `max_hand_size`.
    /// 3. The deck (`new_deck`) becomes empty.
    ///
    /// If the initial deck is empty or the initial hand size is already at or
    /// above `max_hand_size`, the function returns early without modifying the state.
    ///
    /// # Arguments
    ///
    /// * `ref battle_resources` - A mutable reference to `BattleResources`, containing the
    ///                           `hand` and `deck` spans to be modified.
    /// * `amount` - The desired number of cards to draw (`u8`). Must be greater than 0.
    /// * `max_hand_size` - The maximum number of cards allowed in the hand (`u8`).
    /// * `seed` - A `u128` value used to seed the pseudo-random number generator (LCG)
    ///            for selecting cards from the deck.
    ///
    /// # Panics
    ///
    /// * Panics with the message "Amount to draw must be greater than 0" if `amount` is 0.
    /// * Can potentially panic within the loop due to `try_into().unwrap()` if the deck size
    ///   exceeds the capacity of `u128` (extremely unlikely) or if the random index
    ///   from `u128` cannot be converted to `usize` (also unlikely for practical deck sizes).
    /// * Can panic if `remove_card_from_deck` panics (e.g., due to an invalid index,
    ///   although the randomness should prevent this if `get_random_number_zero_indexed`
    ///   works correctly).
    fn draw_cards(ref battle_resources: BattleResources, amount: u8, max_hand_size: u8, seed: u128) {
        assert!(amount > 0, "Amount to draw must be greater than 0");

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
            // stop drawing cards when we reach max hand size or deck is empty
            if new_hand.len() >= max_hand_size.into() || new_deck.len() == 0 {
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

    /// Creates and returns a new `Span<u8>` containing all elements from the input `deck`
    /// except for the element at the specified `index`.
    ///
    /// This is a utility function used, for example, by `draw_cards` to remove a card
    /// from the deck after it has been drawn. It iterates through the input `deck` span
    /// and appends each element to a new array, skipping the element whose index matches
    /// the provided `index`.
    ///
    /// # Arguments
    ///
    /// * `deck` - The input `Span<u8>` representing the deck of cards.
    /// * `index` - The `u8` index of the card to exclude from the new span. Must be a valid
    ///             index within the bounds of the `deck` span.
    ///
    /// # Returns
    ///
    /// A new `Span<u8>` containing the elements of the original `deck` excluding the
    /// element at the specified `index`.
    ///
    /// # Panics
    ///
    /// * Panics with the message "Index is out of bounds" if `index` is greater than or
    ///   equal to the length of the `deck` span.
    fn remove_card_from_deck(deck: Span<u8>, index: u8) -> Span<u8> {
        assert!(index.into() < deck.len(), "Index is out of bounds");

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

#[cfg(test)]
mod tests {
    use core::array::SpanTrait;
    use core::option::OptionTrait;
    use darkshuffle::models::battle::BattleResources;
    use super::{HandUtilsImpl, HandUtilsTrait};

    #[test]
    fn test_remove_card_from_deck_middle() {
        let deck = array![1, 2, 3, 4, 5].span();
        let index_to_remove: u8 = 2; // remove '3'
        let new_deck = HandUtilsImpl::remove_card_from_deck(deck, index_to_remove);
        let expected_deck = array![1, 2, 4, 5].span();
        assert!(new_deck == expected_deck, "Middle card removal failed");
    }

    #[test]
    fn test_remove_card_from_deck_first() {
        let deck = array![1, 2, 3, 4, 5].span();
        let index_to_remove: u8 = 0; // remove '1'
        let new_deck = HandUtilsImpl::remove_card_from_deck(deck, index_to_remove);
        let expected_deck = array![2, 3, 4, 5].span();
        assert!(new_deck == expected_deck, "First card removal failed");
    }

    #[test]
    fn test_remove_card_from_deck_last() {
        let deck = array![1, 2, 3, 4, 5].span();
        let index_to_remove: u8 = 4; // remove '5'
        let new_deck = HandUtilsImpl::remove_card_from_deck(deck, index_to_remove);
        let expected_deck = array![1, 2, 3, 4].span();
        assert!(new_deck == expected_deck, "Last card removal failed");
    }

    #[test]
    fn test_remove_card_from_deck_single() {
        let deck = array![42].span();
        let index_to_remove: u8 = 0;
        let new_deck = HandUtilsImpl::remove_card_from_deck(deck, index_to_remove);
        let expected_deck = array![].span();
        assert!(new_deck == expected_deck, "Single card removal failed");
    }

    #[test]
    #[should_panic(expected: ("Index is out of bounds",))]
    fn test_remove_card_from_deck_out_of_bounds() {
        let deck = array![1, 2, 3].span();
        let index_to_remove: u8 = 3;
        let _new_deck = HandUtilsImpl::remove_card_from_deck(deck, index_to_remove);
    }

    #[test]
    #[should_panic(expected: ("Index is out of bounds",))] // Should panic due to index >= len(0)
    fn test_remove_card_from_deck_empty() {
        let deck = array![].span();
        let index_to_remove: u8 = 0;
        let _new_deck = HandUtilsImpl::remove_card_from_deck(deck, index_to_remove);
    }

    #[test]
    fn test_remove_hand_card_middle() {
        let hand_cards = array![10, 20, 30, 40, 50];
        let deck_cards = array![];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: hand_cards.span(), deck: deck_cards.span(), board: board_cards.span(),
        };
        let card_to_remove: u8 = 30;

        HandUtilsImpl::remove_hand_card(ref battle_resources, card_to_remove);

        let expected_hand = array![10, 20, 40, 50].span();
        assert!(battle_resources.hand == expected_hand, "Middle hand card removal failed");
    }

    #[test]
    fn test_remove_hand_card_first() {
        let hand_cards = array![10, 20, 30, 40, 50];
        let deck_cards = array![];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: hand_cards.span(), deck: deck_cards.span(), board: board_cards.span(),
        };
        let card_to_remove: u8 = 10;

        HandUtilsImpl::remove_hand_card(ref battle_resources, card_to_remove);

        let expected_hand = array![20, 30, 40, 50].span();
        assert!(battle_resources.hand == expected_hand, "First hand card removal failed");
    }

    #[test]
    fn test_remove_hand_card_last() {
        let hand_cards = array![10, 20, 30, 40, 50];
        let deck_cards = array![];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: hand_cards.span(), deck: deck_cards.span(), board: board_cards.span(),
        };
        let card_to_remove: u8 = 50;

        HandUtilsImpl::remove_hand_card(ref battle_resources, card_to_remove);

        let expected_hand = array![10, 20, 30, 40].span();
        assert!(battle_resources.hand == expected_hand, "Last hand card removal failed");
    }

    #[test]
    fn test_remove_hand_card_duplicate() {
        let hand_cards = array![10, 20, 30, 20, 40];
        let deck_cards = array![];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: hand_cards.span(), deck: deck_cards.span(), board: board_cards.span(),
        };
        let card_to_remove: u8 = 20;

        HandUtilsImpl::remove_hand_card(ref battle_resources, card_to_remove);

        let expected_hand = array![10, 30, 20, 40].span();
        assert!(battle_resources.hand == expected_hand, "Duplicate hand card removal failed");
    }

    #[test]
    #[should_panic(expected: ("Card not found in hand",))]
    fn test_remove_hand_card_not_found() {
        let hand_cards = array![10, 20, 30];
        let deck_cards = array![];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: hand_cards.span(), deck: deck_cards.span(), board: board_cards.span(),
        };
        let card_to_remove: u8 = 99; // Card not in hand

        HandUtilsImpl::remove_hand_card(ref battle_resources, card_to_remove);
    }

    #[test]
    #[should_panic(expected: ("Hand is empty",))]
    fn test_remove_hand_card_empty() {
        let hand_cards = array![];
        let deck_cards = array![];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: hand_cards.span(), deck: deck_cards.span(), board: board_cards.span(),
        };
        let card_to_remove: u8 = 1; // Any card ID

        HandUtilsImpl::remove_hand_card(ref battle_resources, card_to_remove);
        // Execution should not reach here
    }

    #[test]
    fn test_remove_hand_card_single() {
        let hand_cards = array![42];
        let deck_cards = array![];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: hand_cards.span(), deck: deck_cards.span(), board: board_cards.span(),
        };
        let card_to_remove: u8 = 42;

        HandUtilsImpl::remove_hand_card(ref battle_resources, card_to_remove);

        let expected_hand = array![].span();
        assert!(battle_resources.hand == expected_hand, "Single hand card removal failed");
        assert!(battle_resources.hand.len() == 0, "Hand should be empty after single remove");
    }

    #[test]
    fn test_draw_cards_simple() {
        let hand_cards = array![];
        let deck_cards = array![1, 2, 3, 4, 5, 6, 7];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: hand_cards.span(), deck: deck_cards.span(), board: board_cards.span(),
        };
        let amount_to_draw: u8 = 3;
        let max_hand_size: u8 = 10;
        let seed: u128 = 12345;

        HandUtilsImpl::draw_cards(ref battle_resources, amount_to_draw, max_hand_size, seed);

        assert!(battle_resources.hand.len() == amount_to_draw.into(), "Hand size incorrect after simple draw");
        assert!(
            battle_resources.deck.len() == (deck_cards.len() - amount_to_draw.into()),
            "Deck size incorrect after simple draw",
        );
    }

    #[test]
    fn test_draw_cards_partial_hand() {
        let initial_hand_cards = array![10, 20];
        let deck_cards = array![1, 2, 3, 4, 5];
        let board_cards = array![];
        let initial_hand_len = initial_hand_cards.len();
        let initial_deck_len = deck_cards.len();
        let mut battle_resources = BattleResources {
            battle_id: 1,
            game_id: 1,
            hand: initial_hand_cards.span(),
            deck: deck_cards.span(),
            board: board_cards.span(),
        };
        let amount_to_draw: u8 = 2;
        let max_hand_size: u8 = 10;
        let seed: u128 = 54321;

        HandUtilsImpl::draw_cards(ref battle_resources, amount_to_draw, max_hand_size, seed);

        let expected_hand_len = initial_hand_len + amount_to_draw.into();
        let expected_deck_len = initial_deck_len - amount_to_draw.into();
        assert!(battle_resources.hand.len() == expected_hand_len, "Hand size incorrect after partial draw");
        assert!(battle_resources.deck.len() == expected_deck_len, "Deck size incorrect after partial draw");
    }

    #[test]
    fn test_draw_cards_empty_deck() {
        let initial_hand_cards = array![10];
        let deck_cards = array![1, 2];
        let board_cards = array![];
        let initial_hand_len = initial_hand_cards.len();
        let initial_deck_len = deck_cards.len();
        let mut battle_resources = BattleResources {
            battle_id: 1,
            game_id: 1,
            hand: initial_hand_cards.span(),
            deck: deck_cards.span(),
            board: board_cards.span(),
        };
        let amount_to_draw: u8 = 3; // More than deck size
        let max_hand_size: u8 = 10;
        let seed: u128 = 67890;

        HandUtilsImpl::draw_cards(ref battle_resources, amount_to_draw, max_hand_size, seed);

        let expected_hand_len = initial_hand_len + initial_deck_len; // Should draw all cards from deck
        let expected_deck_len = 0;
        assert!(battle_resources.hand.len() == expected_hand_len, "Hand size incorrect after emptying deck");
        assert!(battle_resources.deck.len() == expected_deck_len, "Deck should be empty");
    }

    #[test]
    fn test_draw_cards_max_hand() {
        let initial_hand_cards = array![10, 20, 30];
        let deck_cards = array![1, 2, 3, 4, 5];
        let board_cards = array![];
        let initial_hand_len = initial_hand_cards.len();
        let initial_deck_len = deck_cards.len();
        let mut battle_resources = BattleResources {
            battle_id: 1,
            game_id: 1,
            hand: initial_hand_cards.span(),
            deck: deck_cards.span(),
            board: board_cards.span(),
        };
        let amount_to_draw: u8 = 5; // More than hand space available
        let max_hand_size: u8 = 4; // Limit hand size
        let seed: u128 = 98765;

        HandUtilsImpl::draw_cards(ref battle_resources, amount_to_draw, max_hand_size, seed);

        let expected_hand_len = max_hand_size.into(); // Hand should stop at max size
        let cards_actually_drawn = expected_hand_len - initial_hand_len;
        let expected_deck_len = initial_deck_len - cards_actually_drawn;
        assert!(battle_resources.hand.len() == expected_hand_len, "Hand size incorrect after hitting max");
        assert!(battle_resources.deck.len() == expected_deck_len, "Deck size incorrect after hitting max hand size");
    }

    #[test]
    fn test_draw_cards_deck_becomes_empty() {
        let initial_hand_cards = array![10, 20];
        let deck_cards = array![]; // Deck starts empty
        let board_cards = array![];
        let initial_hand_span = initial_hand_cards.span(); // Copy for comparison
        let initial_deck_span = deck_cards.span(); // Copy for comparison
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: initial_hand_span, deck: initial_deck_span, board: board_cards.span(),
        };
        let amount_to_draw: u8 = 3;
        let max_hand_size: u8 = 5;
        let seed: u128 = 11111;

        HandUtilsImpl::draw_cards(ref battle_resources, amount_to_draw, max_hand_size, seed);

        // Hand and deck should remain unchanged
        assert!(battle_resources.hand == initial_hand_span, "Hand changed when deck was empty");
        assert!(battle_resources.deck == initial_deck_span, "Deck changed when deck was empty");
        assert!(battle_resources.deck.len() == 0, "Deck should still be empty");
    }

    #[test]
    fn test_draw_cards_hand_is_full() {
        let initial_hand_cards = array![10, 20, 30];
        let deck_cards = array![1, 2, 3];
        let board_cards = array![];
        let initial_hand_span = initial_hand_cards.span(); // Copy for comparison
        let initial_deck_span = deck_cards.span(); // Copy for comparison
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: initial_hand_span, deck: initial_deck_span, board: board_cards.span(),
        };
        let amount_to_draw: u8 = 2;
        let max_hand_size: u8 = 3; // Hand is already full
        let seed: u128 = 22222;

        HandUtilsImpl::draw_cards(ref battle_resources, amount_to_draw, max_hand_size, seed);

        // Hand and deck should remain unchanged
        assert!(battle_resources.hand == initial_hand_span, "Hand changed when hand was full");
        assert!(battle_resources.deck == initial_deck_span, "Deck changed when hand was full");
        assert!(battle_resources.hand.len() == max_hand_size.into(), "Hand size should remain at max");
    }

    #[test]
    #[should_panic(expected: ("Amount to draw must be greater than 0",))]
    fn test_draw_cards_zero_amount() {
        let initial_hand_cards = array![10];
        let deck_cards = array![1, 2, 3];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1,
            game_id: 1,
            hand: initial_hand_cards.span(),
            deck: deck_cards.span(),
            board: board_cards.span(),
        };
        let amount_to_draw: u8 = 0; // Draw zero cards
        let max_hand_size: u8 = 5;
        let seed: u128 = 33333;

        HandUtilsImpl::draw_cards(ref battle_resources, amount_to_draw, max_hand_size, seed);
    }

    #[test]
    fn draw_cards_more_than_available_in_deck() {
        let deck_cards = array![1, 2];
        let hand_cards = array![];
        let board_cards = array![];
        let mut battle_resources = BattleResources {
            battle_id: 1, game_id: 1, hand: hand_cards.span(), deck: deck_cards.span(), board: board_cards.span(),
        };

        let amount_to_draw: u8 = 3;
        let max_hand_size: u8 = 5;
        let seed: u128 = 12345;

        HandUtilsImpl::draw_cards(ref battle_resources, amount_to_draw, max_hand_size, seed);
    }
}
