// Dark Shuffle Game Token
use starknet::ContractAddress;

#[starknet::interface]
trait IDarkShuffleGameToken<TState> {
    fn mint(ref self: TState, recipient: ContractAddress, token_id: u256, settings_id: u32);
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
        IERC721DispatcherTrait, IERC721MetadataCamelOnly, ERC721ABI
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
    impl ERC721Impl of ERC721ABI<ContractState> {
        fn balance_of(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            ERC721::balance_of(self, account)
        }

        fn owner_of(self: @ComponentState<TContractState>, token_id: u256) -> ContractAddress {
            ERC721::owner_of(self, token_id)
        }

        fn safe_transfer_from(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            ERC721::safe_transfer_from(ref self, from, to, token_id, data);
        }

        fn transfer_from(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256
        ) {
            ERC721::transfer_from(ref self, from, to, token_id);
        }

        fn approve(ref self: ComponentState<TContractState>, to: ContractAddress, token_id: u256) {
            ERC721::approve(ref self, to, token_id);
        }

        fn set_approval_for_all(
            ref self: ComponentState<TContractState>, operator: ContractAddress, approved: bool
        ) {
            ERC721::set_approval_for_all(ref self, operator, approved);
        }

        fn get_approved(self: @ComponentState<TContractState>, token_id: u256) -> ContractAddress {
            ERC721::get_approved(self, token_id)
        }

        fn is_approved_for_all(
            self: @ComponentState<TContractState>, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            ERC721::is_approved_for_all(self, owner, operator)
        }

        // IERC721Metadata
        fn name(self: @ComponentState<TContractState>) -> ByteArray {
            ERC721Metadata::name(self)
        }

        fn symbol(self: @ComponentState<TContractState>) -> ByteArray {
            ERC721Metadata::symbol(self)
        }

        /// Returns the Uniform Resource Identifier (URI) for the `token_id` token.
        /// If the URI is not set, the return value will be an empty ByteArray.
        ///
        /// Requirements:
        ///
        /// - `token_id` exists.
        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self.erc721._require_owned(token_id);
            let (hero_name, hero_health, hero_xp, state, cards) = IGameDispatcher {
                contract_address: self.ownable.Ownable_owner.read()
            }.get_game_data(token_id.try_into().unwrap());

            create_metadata(token_id, hero_name, hero_health, hero_xp, state, cards)
        }

        // IERC721CamelOnly
        fn balanceOf(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            ERC721CamelOnly::balanceOf(self, account)
        }

        fn ownerOf(self: @ComponentState<TContractState>, tokenId: u256) -> ContractAddress {
            ERC721CamelOnly::ownerOf(self, tokenId)
        }

        fn safeTransferFrom(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            tokenId: u256,
            data: Span<felt252>
        ) {
            ERC721CamelOnly::safeTransferFrom(ref self, from, to, tokenId, data);
        }

        fn transferFrom(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            tokenId: u256
        ) {
            ERC721CamelOnly::transferFrom(ref self, from, to, tokenId);
        }

        fn setApprovalForAll(
            ref self: ComponentState<TContractState>, operator: ContractAddress, approved: bool
        ) {
            ERC721CamelOnly::setApprovalForAll(ref self, operator, approved);
        }

        fn getApproved(self: @ComponentState<TContractState>, tokenId: u256) -> ContractAddress {
            ERC721CamelOnly::getApproved(self, tokenId)
        }

        fn isApprovedForAll(
            self: @ComponentState<TContractState>, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            ERC721CamelOnly::isApprovedForAll(self, owner, operator)
        }

        // IERC721MetadataCamelOnly
        fn tokenURI(self: @ComponentState<TContractState>, tokenId: u256) -> ByteArray {
            ERC721MetadataCamelOnly::tokenURI(self, tokenId)
        }

        // ISRC5
        fn supports_interface(
            self: @ComponentState<TContractState>, interface_id: felt252
        ) -> bool {
            let src5 = get_dep_component!(self, SRC5);
            src5.supports_interface(interface_id)
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

        fn settings_id(self: @ContractState, token_id: u256) -> u32 {
            self.settings_id.entry(token_id).read()
        }

        fn get_token_of_owner_by_index(self: @ContractState, owner: ContractAddress, index: u256) -> u256 {
            self.erc721_enumerable.token_of_owner_by_index(owner, index)
        }
    }
}
