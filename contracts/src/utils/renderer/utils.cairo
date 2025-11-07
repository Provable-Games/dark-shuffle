use alexandria_encoding::base64::Base64Encoder;
use core::array::{ArrayTrait, SpanTrait};
use core::clone::Clone;
use core::traits::Into;
use darkshuffle::utils::renderer::encoding::{U256BytesUsedTraitImpl, bytes_base64_encode};
use graffiti::json::JsonImpl;

pub fn encode_card_name(name: felt252) -> ByteArray {
    let mut encoded_name = Default::default();
    encoded_name.append_word(name, U256BytesUsedTraitImpl::bytes_used(name.into()).into());
    encoded_name
}

fn logo() -> ByteArray {
    "<g transform='translate(20,25) scale(0.5)'><path d=\"M32.914 31.133a135 135 0 0 0-7.312-11.575l1.974-1.215 2.082 2.854a103 103 0 0 0 4.803-2.061q2.403-1.11 5.23-1.216 6.46.105 9.875 4.862a30.7 30.7 0 0 1 2.829 4.968 134 134 0 0 1 1.974 5.656q.427 2.272 1.068 4.65a26.6 26.6 0 0 0 1.654 4.652 10.7 10.7 0 0 0 2.722 3.594c2.317 2.085 6.06 2.085 8.377 0a10.7 10.7 0 0 0 2.722-3.594 26.6 26.6 0 0 0 1.654-4.651 62 62 0 0 0 1.068-4.651 134 134 0 0 1 1.975-5.655 30.7 30.7 0 0 1 2.828-4.969q3.417-4.756 9.874-4.862 2.83.106 5.23 1.215a103 103 0 0 0 4.804 2.062l2.082-2.854 1.975 1.215a135 135 0 0 0-7.312 11.575 10 10 0 0 1-2.616-.951 23 23 0 0 0-2.562-1.427q-1.173-.634-2.828-1.216-1.602-.528-3.683-.528-2.882 0-4.964 1.532-2.295 1.64-2.295 4.651 0 2.696 1.761 5.286 1.655 2.695 4.164 3.91a22.1 22.1 0 0 0 7.418 1.058q2.082 0 4.163-.212v7.505h-9.713L67.182 115.2l3.155-57.837c.196-3.598-2.697-6.622-6.335-6.622s-6.532 3.024-6.336 6.622l3.155 57.837L44.07 50.741h-9.714v-7.505q2.08.212 4.163.212 3.789.105 7.419-1.057 2.508-1.215 4.163-3.911 1.76-2.59 1.76-5.286 0-3.012-2.294-4.65-2.081-1.534-4.964-1.533-2.081 0-3.682.528-1.656.582-2.83 1.216-1.334.633-2.561 1.427a10 10 0 0 1-2.615.951\"/></g>"
}

fn game_state(state: u8) -> ByteArray {
    match state {
        0 => "In Draft",
        1 => "In Battle",
        2 => "Exploring",
        3 => "Game Over",
        _ => "Unknown",
    }
}

fn create_text(
    text: ByteArray, x: ByteArray, y: ByteArray, fontsize: ByteArray, baseline: ByteArray, text_anchor: ByteArray,
) -> ByteArray {
    "<text x='"
        + x
        + "' y='"
        + y
        + "' font-size='"
        + fontsize
        + "' text-anchor='"
        + text_anchor
        + "' dominant-baseline='"
        + baseline
        + "'>"
        + text
        + "</text>"
}

fn combine_elements(ref elements: Span<ByteArray>) -> ByteArray {
    let mut count: u8 = 1;

    let mut combined: ByteArray = "";
    loop {
        match elements.pop_front() {
            Option::Some(element) => {
                combined += element.clone();

                count += 1;
            },
            Option::None(()) => { break; },
        };
    };

    combined
}

fn create_rect() -> ByteArray {
    "<rect x='0.5' y='0.5' width='469' height='599' rx='27.5' fill='black' stroke='#ffe97f'/>"
}

// @notice Generates an SVG string for game token uri
// @param internals The internals of the SVG
// @return The generated SVG string
pub fn create_svg(
    token_id: u64, hero_name: felt252, hero_health: u8, hero_xp: u16, state: u8, cards: Span<felt252>,
) -> ByteArray {
    let rect = create_rect();
    let logo_element = logo();
    let mut _name = Default::default();

    if hero_name != 0 {
        _name.append_word(hero_name, U256BytesUsedTraitImpl::bytes_used(hero_name.into()).into());
    }

    let _game_id = format!("{}", token_id);
    let _xp = format!("{}", hero_xp);
    let _health = format!("{}", hero_health);

    // Combine all elements
    let mut elements = array![
        rect, logo_element, create_text("#" + _game_id.clone(), "100", "50", "24", "middle", "left"),
    ];

    if hero_xp != 0 {
        elements.append(create_text(_name.clone(), "30", "120", "20", "middle", "left"));
        elements.append(create_text(game_state(state).clone(), "100", "72", "16", "middle", "left"));
        elements.append(create_text("XP: " + _xp.clone(), "30", "150", "18", "middle", "left"));
        elements.append(create_text("HP: " + _health.clone(), "30", "175", "18", "middle", "left"));
        elements.append(create_text("Draft", "30", "220", "28", "middle", "right"));
    } else {
        elements.append(create_text("Game not started", "100", "72", "16", "middle", "left"));
    }

    let mut i = 0;
    while i < cards.len() {
        let mut x = "30";
        let mut y = 260 + (i * 34);

        if i > 9 {
            x = "250";
            y = 260 + ((i - 10) * 34);
        }

        let card_name: felt252 = *cards.at(i);
        let encoded_card_name = encode_card_name(card_name);

        let format_card_name = format!("{}. {}", (i + 1).clone(), encoded_card_name);
        let y_position = format!("{}", y);
        elements.append(create_text(format_card_name, x, y_position, "18", "middle", "left"));
        i += 1;
    };

    let mut elements = elements.span();
    let image =
        "<svg xmlns='http://www.w3.org/2000/svg' width='470' height='600'><style>text{text-transform: uppercase;font-family: Courier, monospace;fill: #ffe97f;}g{fill: #ffe97f;}</style>"
        + combine_elements(ref elements)
        + "</svg>";

    format!("data:image/svg+xml;base64,{}", bytes_base64_encode(image))
}

pub fn create_metadata(
    token_id: u64, hero_name: felt252, hero_health: u8, hero_xp: u16, state: u8, cards: Span<felt252>,
) -> ByteArray {
    let base64_image = create_svg(token_id, hero_name, hero_health, hero_xp, state, cards);

    let mut metadata = JsonImpl::new()
        .add("name", "Game" + " #" + format!("{}", token_id))
        .add("description", "An NFT representing ownership of a game of Dark Shuffle.")
        .add("image", base64_image);

    let mut _name = Default::default();
    if hero_name != 0 {
        _name.append_word(hero_name, U256BytesUsedTraitImpl::bytes_used(hero_name.into()).into());
    }

    let name: ByteArray = JsonImpl::new().add("trait", "Name").add("value", _name).build();
    let xp: ByteArray = JsonImpl::new().add("trait", "XP").add("value", format!("{}", hero_xp)).build();
    let health: ByteArray = JsonImpl::new().add("trait", "Health").add("value", format!("{}", hero_health)).build();

    let attributes = array![name, xp, health].span();

    let metadata = metadata.add_array("attributes", attributes).build();

    format!("data:application/json;base64,{}", bytes_base64_encode(metadata))
}


#[cfg(test)]
mod tests {
    use core::array::ArrayTrait;
    use super::create_metadata;

    #[test]
    fn test_metadata() {
        let _current_1 = create_metadata(
            1000000,
            'Await',
            50,
            1,
            1,
            array![
                'Wolf',
                'Colossus',
                'Ogre',
                'Dragon',
                'Sprite',
                'Warlock',
                'Kraken',
                'Nemeanlion',
                'Ghoul',
                'Fairy',
                'Direwolf',
                'Gnome',
                'Pheonix',
                'Pegasus',
                'Golem',
                'Spider',
                'Rat',
                'Skeleton',
                'Leprechaun',
                'Minotaur',
            ]
                .span(),
        );

        let _current_2 = create_metadata(
            999, 'Await', 50, 423, 0, array!['Wolf', 'Colossus', 'Ogre', 'Dragon', 'Sprite'].span(),
        );

        let _current_3 = create_metadata(999, 0, 0, 0, 0, array![].span());
    }
}

