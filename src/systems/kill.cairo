#[system]
mod kill{
    use starknet::ContractAddress;
    use dojo_werewolf::components::{Player};
    use dojo_werewolf::components::{GameState};
    use dojo_werewolf::components::{RoundState};
    use dojo::world::Context;
    use core::array::SpanTrait;
    use debug::PrintTrait;
    use core::traits::Into;

    fn check_game_end(ctx :Context, game_id:u32, game_state: GameState) -> (bool, u8) {
        let mut i: usize = 0;
        let mut live_famer_count = 0;
        let mut live_wolfman_count = 0;
        let mut is_end = false;
        let mut winer = 0;
        loop{
            if i >= game_state.player_count{
                break;
            }
            let player = get !(ctx.world, (game_id, i),Player);
            if !player.is_dead{
                if player.role == 0{
                    live_famer_count += 1;
                }else{
                    live_wolfman_count += 1;
                }
            }
            i += 1;
        };
        if live_famer_count == 0{
            is_end = true;
            winer = 1;
        }else if live_wolfman_count == 0{
            is_end = true;
            winer = 0;
        }else{
            is_end = false;
        }

        if is_end{
            set !(ctx.world, GameState{
                game_id: game_id,
                player_count: game_state.player_count,
                is_end: true,
                is_started: true,
                winer: winer
            });
        }

        return (is_end, winer);
    }

    fn execute(ctx: Context, game_id: u32, player_index: u32,target_index: u32){
        let game_state:GameState = get !(ctx.world, game_id, GameState);
        assert(game_state.is_started, 'game not started');
        assert(!game_state.is_end, 'game ended');
        let player: Player= get !(ctx.world, (game_id, player_index), Player);
        assert(!player.is_dead, 'player is dead');
        assert(player.role == 1, 'only wolfman can kill people');
        let target_player: Player= get !(ctx.world, (game_id, target_index), Player);
        assert(!target_player.is_dead, 'target player is dead');
        let round_state: RoundState = get !(ctx.world, game_id, RoundState);
        assert(round_state.day_state == 0, ' must kill at night');

        set !(ctx.world, Player{
            game_id: game_id,
            index: target_index,
            player_address: target_player.player_address,
            role: target_player.role,
            is_dead: true,
            nick_name: target_player.nick_name,
            votes_num: 0
        });

        let (is_end, winer) = check_game_end(ctx, game_id, game_state);
        is_end.print();
        winer.print();


        if !is_end{
            set!(ctx.world, RoundState{
                game_id: game_id,
                rounds: round_state.rounds+1,
                day_state: 1,
            })
        }else{
            'game end'.print();
            if winer == 0{
                'famer win'.print();
            }else{
                'wolfman win'.print();
            }
        }
        
    }
}