// Dark Shuffle Game Token
use starknet::ContractAddress;

#[starknet::interface]
trait IDarkShuffleGameToken<TState> {
    fn mint(ref self: TState, recipient: ContractAddress, token_id: u256, settings_id: u32);
    fn attach_season_pass(ref self: TState, token_id: u256, season_id: u32);
    fn season_pass(self: @TState, token_id: u256) -> u32;
    fn settings_id(self: @TState, token_id: u256) -> u32;
    fn get_token_of_owner_by_index(self: @TState, owner: ContractAddress, index: u256) -> u256;
}

#[starknet::interface]
trait IGame<TState> {
    fn get_game_data(self: @TState, token_id: u64) -> (felt252, u8, u16, u32, u8, Span<felt252>);
}

#[starknet::contract]
mod DarkShuffleGameToken {
    use super::{IGame, IGameDispatcher, IGameDispatcherTrait};
    use dsgt::utils::create_metadata;
    use starknet::ContractAddress;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map};
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use openzeppelin::token::erc721::extensions::ERC721EnumerableComponent;
    use openzeppelin::token::erc721::interface::{
        IERC721Metadata, IERC721MetadataDispatcher, IERC721MetadataDispatcherTrait, IERC721Dispatcher,
        IERC721DispatcherTrait, IERC721MetadataCamelOnly,
    };

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721EnumerableComponent, storage: erc721_enumerable, event: ERC721EnumerableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721EnumerableImpl = ERC721EnumerableComponent::ERC721EnumerableImpl<ContractState>;

    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;
    impl ERC721EnumerableInternalImpl = ERC721EnumerableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        season_pass: Map<u256, u32>,
        settings_id: Map<u256, u32>,

        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        erc721_enumerable: ERC721EnumerableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        ERC721EnumerableEvent: ERC721EnumerableComponent::Event,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
    ) {
        self.erc721.initializer("Dark Shuffle Game Token", "DSGT", "");
        self.ownable.initializer(owner);
        self.erc721_enumerable.initializer();
    }

    #[abi(embed_v0)]
    impl ERC721Metadata of IERC721Metadata<ContractState> {
        /// Returns the NFT name.
        fn name(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_name.read()
        }

        /// Returns the NFT symbol.
        fn symbol(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_symbol.read()
        }

        /// Returns the Uniform Resource Identifier (URI) for the `token_id` token.
        /// If the URI is not set, the return value will be an empty ByteArray.
        ///
        /// Requirements:
        ///
        /// - `token_id` exists.
        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self.erc721._require_owned(token_id);
            let (hero_name, hero_health, hero_xp, season_id, state, cards) = IGameDispatcher {
                contract_address: self.ownable.Ownable_owner.read()
            }.get_game_data(token_id.try_into().unwrap());

            create_metadata(token_id, hero_name, hero_health, hero_xp, season_id, state, cards)
        }
    }

    impl ERC721HooksImpl of ERC721Component::ERC721HooksTrait<ContractState> {
        fn before_update(
            ref self: ERC721Component::ComponentState<ContractState>,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress
        ) {
            let mut contract_state = self.get_contract_mut();
            contract_state.erc721_enumerable.before_update(to, token_id);
        }
    }
    
    #[abi(embed_v0)]
    impl DarkShuffleGameTokenImpl of super::IDarkShuffleGameToken<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, token_id: u256, settings_id: u32) {
            self.ownable.assert_only_owner();
            self.erc721.mint(recipient, token_id);
            self.settings_id.entry(token_id).write(settings_id);
        }

        fn attach_season_pass(ref self: ContractState, token_id: u256, season_id: u32) {
            self.ownable.assert_only_owner();
            assert!(self.erc721.owner_of(token_id) != Zeroable::zero(), "ESP: Game token does not exist");

            // add season pass to game token
            let season_pass = self.season_pass.entry(token_id).read();
            assert!(season_pass == 0, "ESP: Game token already has a season pass");

            self.season_pass.entry(token_id).write(season_id);
        }

        fn season_pass(self: @ContractState, token_id: u256) -> u32 {
            self.season_pass.entry(token_id).read()
        }

        fn settings_id(self: @ContractState, token_id: u256) -> u32 {
            self.settings_id.entry(token_id).read()
        }

        fn get_token_of_owner_by_index(self: @ContractState, owner: ContractAddress, index: u256) -> u256 {
            self.erc721_enumerable.token_of_owner_by_index(owner, index)
        }
    }
}
