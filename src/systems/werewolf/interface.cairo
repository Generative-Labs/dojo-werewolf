use dojo::world::IWorldDispatcher;
use starknet::ContractAddress;
#[starknet::interface]
trait IWereWolfGame<TContractState> {
    fn init(self: @TContractState, world: IWorldDispatcher) -> u32;
    fn join(self: @TContractState, world: IWorldDispatcher, game_id: u32, player_address: ContractAddress, nick_name: felt252) -> u32;
    fn start(self: @TContractState, world: IWorldDispatcher, game_id: u32);
    fn kill(self: @TContractState, world: IWorldDispatcher, game_id: u32, player_index: u32,target_index: u32);
    fn vote(self: @TContractState, world: IWorldDispatcher, game_id: u32, player_index: u32,target_index: u32);
}