use darkshuffle::utils::random;

#[generate_trait]
impl DraftUtilsImpl of DraftUtilsTrait {
    // TODO: Consider using the algorithm from LS Market in which we select a starting point and an offset
    fn get_draft_options(mut entropy: u128, include_spells: bool) -> Span<u8> {
        let mut card_1 = 0;
        let mut card_2 = 0;
        let mut card_3 = 0;

        card_1 = random::get_random_card_id(entropy, include_spells);
        entropy = random::LCG(entropy);
        card_2 = random::get_random_card_id(entropy, include_spells);
        entropy = random::LCG(entropy);
        card_3 = random::get_random_card_id(entropy, include_spells);

        loop {
            if card_1 == card_2 {
                entropy = random::LCG(entropy);
                card_2 = random::get_random_card_id(entropy, include_spells);
                continue;
            }

            if card_1 == card_3 {
                entropy = random::LCG(entropy);
                card_3 = random::get_random_card_id(entropy, include_spells);
                continue;
            }

            if card_2 == card_3 {
                entropy = random::LCG(entropy);
                card_3 = random::get_random_card_id(entropy, include_spells);
                continue;
            }

            break;
        };

        array![card_1, card_2, card_3].span()
    }
}
