use core::debug::PrintTrait;
#[system]
mod join{
    use dojo::world::Context;
    use dojo_werewolf::components::{Player};
    use dojo_werewolf::components::{GameState};
    use traits::Into;
    use debug::PrintTrait;
    use starknet::ContractAddress;

    fn execute(ctx: Context, game_id: u32, player_address: ContractAddress, nick_name: felt252) -> u32{
        let game_state: GameState = get!(ctx.world, game_id, GameState);
        let index = game_state.player_count;
        let new_player_count = index + 1;
        let mut role = 0;
        if new_player_count <= 3{
            role = 1;
        }

        set!(ctx.world, GameState{
            game_id:game_id,
            player_count: new_player_count,
            is_end:false,
            is_started:false,
            winer:game_state.winer
        });

        set!(ctx.world, Player{
            game_id:game_id,
            index:index,
            player_address:player_address, 
            role:role,
            is_dead:false,
            nick_name:nick_name,
            votes_num:0
        });

        return index;
    }
}