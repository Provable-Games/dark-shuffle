#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Draft {
    #[key]
    pub game_id: u64,
    pub options: Span<u8>,
    pub cards: Span<u8>,
}

#[generate_trait]
pub impl DraftOwnerImpl of DraftOwnerTrait {
    fn add_card(ref self: Draft, card_index: u8) {
        let mut new_cards = array![];

        let mut i = 0;
        while i < self.cards.len() {
            new_cards.append(*self.cards.at(i));
            i += 1;
        };

        new_cards.append(card_index);
        self.cards = new_cards.span();
    }
}
