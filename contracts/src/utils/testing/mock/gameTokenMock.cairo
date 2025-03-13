// Game Token Mock
use starknet::ContractAddress;

#[starknet::interface]
trait IGameTokenMock<TState> {
    fn mint(ref self: TState, recipient: ContractAddress, token_id: u256, settings_id: u32);
    fn settings_id(self: @TState, token_id: u256) -> u32;
}

#[starknet::contract]
pub mod GameTokenMock {
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::ERC721Component;
    use openzeppelin_token::erc721::ERC721HooksEmptyImpl;
    use starknet::ContractAddress;
    use starknet::storage::{Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;

    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        settings_id: Map<u256, u32>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.erc721.initializer("Dark Shuffle Game Token", "DSGT", "");
    }

    #[abi(embed_v0)]
    impl GameTokenMockImpl of super::IGameTokenMock<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, token_id: u256, settings_id: u32) {
            self.erc721.mint(recipient, token_id);
            self.settings_id.entry(token_id).write(settings_id);
        }

        fn settings_id(self: @ContractState, token_id: u256) -> u32 {
            self.settings_id.entry(token_id).read()
        }
    }
}
