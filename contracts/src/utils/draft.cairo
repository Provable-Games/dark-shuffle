use dojo::world::WorldStorage;
use dojo::model::ModelStorage;
use darkshuffle::models::card::Card;
use darkshuffle::utils::random;
use darkshuffle::models::config::GameSettings;

#[generate_trait]
impl DraftUtilsImpl of DraftUtilsTrait {
    fn get_weighted_draft_list(world: WorldStorage, game_settings: GameSettings) -> Span<u8> {
        let mut draft_list = array![];

        let mut i: u8 = 0;
        while i.into() < game_settings.card_ids.len() {
            let card: Card = world.read_model(*game_settings.card_ids.at(i.into()));
            let card_rarity: u8 = card.rarity.into();
            let weight = *game_settings.card_rarity_weights.at(card_rarity.into());

            let mut j = 0;
            while j < weight {
                draft_list.append(i);
                j += 1;
            };

            i += 1;
        };

        draft_list.span()
    }

    fn get_draft_options(mut entropy: u128, card_pool: Span<u8>) -> Span<u8> {
        let mut card_1 = 0;
        let mut card_2 = 0;
        let mut card_3 = 0;

        card_1 = random::get_random_card_id(entropy, card_pool);
        entropy = random::LCG(entropy);
        card_2 = random::get_random_card_id(entropy, card_pool);
        entropy = random::LCG(entropy);
        card_3 = random::get_random_card_id(entropy, card_pool);

        loop {
            if card_1 == card_2 {
                entropy = random::LCG(entropy);
                card_2 = random::get_random_card_id(entropy, card_pool);
                continue;
            }

            if card_1 == card_3 {
                entropy = random::LCG(entropy);
                card_3 = random::get_random_card_id(entropy, card_pool);
                continue;
            }

            if card_2 == card_3 {
                entropy = random::LCG(entropy);
                card_3 = random::get_random_card_id(entropy, card_pool);
                continue;
            }

            break;
        };

        array![card_1, card_2, card_3].span()
    }
}
