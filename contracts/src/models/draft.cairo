#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Draft {
    #[key]
    game_id: u64,
    options: Span<u8>,
    cards: Span<u8>,
}

#[generate_trait]
impl DraftOwnerImpl of DraftOwnerTrait {
    fn add_card(ref self: Draft, card_id: u8) {
        let mut new_cards = array![];

        let mut i = 0;
        while i < self.cards.len() {
            new_cards.append(*self.cards.at(i));
            i += 1;
        };

        new_cards.append(card_id);
        self.cards = new_cards.span();
    }
}
