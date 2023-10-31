use array::ArrayTrait;
use dojo_werewolf::models::{player, Player};
use dojo_werewolf::models::{round_state, RoundState};
use dojo_werewolf::models::{game_state, GameState};
use dojo::test_utils::spawn_test_world;
use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
use core::traits::Into;
use dojo_werewolf::systems::init::init;
use dojo_werewolf::systems::join::join;
use dojo_werewolf::systems::start::start;
use dojo_werewolf::systems::vote::vote;
use dojo_werewolf::systems::kill::kill;
use debug::PrintTrait;
use core::array::SpanTrait;

fn setup_world() -> IWorldDispatcher {
    // components
    let mut components = array![game_state::TEST_CLASS_HASH, player::TEST_CLASS_HASH, round_state::TEST_CLASS_HASH];
    // systems
    let mut systems = array![init::TEST_CLASS_HASH, join::TEST_CLASS_HASH, start::TEST_CLASS_HASH, vote::TEST_CLASS_HASH, kill::TEST_CLASS_HASH];
    let world = spawn_test_world(components, systems);
    return world;
}

fn test_start(){
    let world = setup_world();
    let mut res = world.execute('init',array![]);
    let game_id = serde::Serde::<u32>::deserialize(ref res);
    match game_id{
        Option::Some(id)=>{
            world.execute('join', array![id.into(), 1.into(), 'player_1'.into()]);
            world.execute('join', array![id.into(), 2.into(), 'player_2'.into()]);
            world.execute('join', array![id.into(), 3.into(), 'player_3'.into()]);
            world.execute('join', array![id.into(), 4.into(), 'player_4'.into()]);
            world.execute('join', array![id.into(), 5.into(), 'player_5'.into()]);
            world.execute('join', array![id.into(), 6.into(), 'player_6'.into()]);
            world.execute('start', array![id.into()]);
            world.execute('kill', array![id.into(), 0.into(), 4.into()]);
            world.execute('vote', array![id.into(), 0.into(), 5.into()]);
            world.execute('vote', array![id.into(), 1.into(), 5.into()]);
            world.execute('vote', array![id.into(), 2.into(), 5.into()]);
            world.execute('vote', array![id.into(), 3.into(), 5.into()]);
            // world.execute('vote', array![id.into(), 4.into(), 2.into()]);
            world.execute('vote', array![id.into(), 5.into(), 2.into()]);
            world.execute('kill', array![id.into(), 0.into(), 3.into()]);
        },
        Option::None(())=>{
            'none game id'.print()
        }
    }
}

#[test]
#[available_gas(3000000000000000)]
fn test_all(){
    test_start();
}