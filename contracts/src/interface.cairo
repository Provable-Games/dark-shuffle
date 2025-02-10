use starknet::ContractAddress;

// TODO: Remove
#[starknet::interface]
trait IGameToken<TState> {
    fn mint(ref self: TState, recipient: ContractAddress, token_id: u256, settings_id: u32);
    fn attach_season_pass(ref self: TState, token_id: u256, season_id: u32);
    fn season_pass(self: @TState, token_id: u256) -> u32;
    fn settings_id(self: @TState, token_id: u256) -> u32;
    fn get_token_of_owner_by_index(self: @TState, owner: ContractAddress, index: u256) -> u256;
}
