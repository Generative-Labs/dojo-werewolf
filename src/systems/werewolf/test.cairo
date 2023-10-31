use dojo::test_utils::deploy_contract;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo_werewolf::systems::werewolf::interface::{IWereWolfGameDispatcher, IWereWolfGameDispatcherTrait};
use dojo::test_utils::spawn_test_world;
use array::ArrayTrait;
use starknet::{
    syscalls::deploy_syscall,ClassHash, ContractAddress
};
use dojo_werewolf::systems::werewolf::contract::werewolf_systems;
use dojo_werewolf::models::{player, Player};
use dojo_werewolf::models::{round_state, RoundState};
use dojo_werewolf::models::{game_state, GameState};
use core::traits::Into;
use debug::PrintTrait;
use starknet::contract_address::Felt252TryIntoContractAddress;
// use core::array::SpanTrait;

#[test]
#[available_gas(3000000000000000)]
fn test_all(){
    let mut models = array![
        player::TEST_CLASS_HASH,
        round_state::TEST_CLASS_HASH,
        game_state::TEST_CLASS_HASH];

    let world: IWorldDispatcher = spawn_test_world(models);
    starknet::testing::set_contract_address(world.executor());
    let (werewolf_systems, _) = deploy_syscall(werewolf_systems::TEST_CLASS_HASH.try_into().unwrap(), 0, array![].span(), false).unwrap();
    let werewolf_systems_dispatcher = IWereWolfGameDispatcher {
        contract_address: werewolf_systems
    };
    let game_id = werewolf_systems_dispatcher.init(world);
    game_id.print();
    werewolf_systems_dispatcher.join(world, game_id.into(), 1.try_into().unwrap(), 'player_1'.into());
    werewolf_systems_dispatcher.join(world, game_id.into(), 2.try_into().unwrap(), 'player_2'.into());
    werewolf_systems_dispatcher.join(world, game_id.into(), 3.try_into().unwrap(), 'player_3'.into());
    werewolf_systems_dispatcher.join(world, game_id.into(), 4.try_into().unwrap(), 'player_4'.into());
    werewolf_systems_dispatcher.join(world, game_id.into(), 5.try_into().unwrap(), 'player_5'.into());
    werewolf_systems_dispatcher.join(world, game_id.into(), 6.try_into().unwrap(), 'player_6'.into());
    werewolf_systems_dispatcher.start(world, game_id.into());
    werewolf_systems_dispatcher.kill(world, game_id.into(), 0.try_into().unwrap(), 4.try_into().unwrap());
    werewolf_systems_dispatcher.vote(world, game_id.into(), 0.try_into().unwrap(), 5.try_into().unwrap());
    werewolf_systems_dispatcher.vote(world, game_id.into(), 1.try_into().unwrap(), 5.try_into().unwrap());
    werewolf_systems_dispatcher.vote(world, game_id.into(), 2.try_into().unwrap(), 5.try_into().unwrap());
    werewolf_systems_dispatcher.vote(world, game_id.into(), 3.try_into().unwrap(), 5.try_into().unwrap());
    werewolf_systems_dispatcher.vote(world, game_id.into(), 5.try_into().unwrap(), 2.try_into().unwrap());
    
    werewolf_systems_dispatcher.kill(world, game_id.into(), 0.try_into().unwrap(), 3.try_into().unwrap());
}