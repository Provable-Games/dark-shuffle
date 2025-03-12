use darkshuffle::models::card::{Card, CardRarity};
use darkshuffle::models::config::GameSettings;
use darkshuffle::utils::random;
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;

#[generate_trait]
impl DraftUtilsImpl of DraftUtilsTrait {
    fn get_weighted_draft_list(world: WorldStorage, game_settings: GameSettings) -> Span<u8> {
        let mut draft_list = array![];

        let mut i: u8 = 0;
        while i.into() < game_settings.card_ids.len() {
            let card: Card = world.read_model(*game_settings.card_ids.at(i.into()));
            let card_rarity: CardRarity = card.rarity.into();
            let weight = match card_rarity {
                CardRarity::Common => game_settings.card_rarity_weights.common,
                CardRarity::Uncommon => game_settings.card_rarity_weights.uncommon,
                CardRarity::Rare => game_settings.card_rarity_weights.rare,
                CardRarity::Epic => game_settings.card_rarity_weights.epic,
                CardRarity::Legendary => game_settings.card_rarity_weights.legendary,
                _ => 0,
            };

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

        card_1 = random::get_random_card_index(entropy, card_pool);
        entropy = random::LCG(entropy);
        card_2 = random::get_random_card_index(entropy, card_pool);
        entropy = random::LCG(entropy);
        card_3 = random::get_random_card_index(entropy, card_pool);

        loop {
            if card_1 == card_2 {
                entropy = random::LCG(entropy);
                card_2 = random::get_random_card_index(entropy, card_pool);
                continue;
            }

            if card_1 == card_3 {
                entropy = random::LCG(entropy);
                card_3 = random::get_random_card_index(entropy, card_pool);
                continue;
            }

            if card_2 == card_3 {
                entropy = random::LCG(entropy);
                card_3 = random::get_random_card_index(entropy, card_pool);
                continue;
            }

            break;
        };

        array![card_1, card_2, card_3].span()
    }

    fn auto_draft(mut entropy: u128, card_pool: Span<u8>, draft_size: u8) -> Span<u8> {
        let mut draft_list = array![];

        let mut i = 0;
        while i < draft_size {
            let card_index = random::get_random_card_index(entropy, card_pool);
            draft_list.append(card_index);
            entropy = random::LCG(entropy);
            i += 1;
        };

        draft_list.span()
    }
}
