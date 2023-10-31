#[dojo::contract]
mod werewolf_systems{
    use starknet::ContractAddress;
    use dojo_werewolf::models::{GameState};
    use dojo_werewolf::models::{RoundState};
    use dojo_werewolf::models::{Player};
    use debug::PrintTrait;
    use core::array::SpanTrait;
    use traits::Into;
    use dojo_werewolf::systems::werewolf::interface::IWereWolfGame;

    fn check_game_end(world: IWorldDispatcher, game_id:u32, game_state: GameState) -> (bool, u8) {
        let mut i: usize = 0;
        let mut live_famer_count = 0;
        let mut live_wolfman_count = 0;
        let mut is_end = false;
        let mut winer = 0;
        loop{
            if i >= game_state.player_count{
                break;
            }
            let player = get !(world, (game_id, i),Player);
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
            set !(world, GameState{
                game_id: game_id,
                player_count: game_state.player_count,
                is_end: true,
                is_started: true,
                winer: winer
            });
        }

        return (is_end, winer);
    }

    fn roll_back_vote(world: IWorldDispatcher, game_id: u32, game_state:GameState){
        let mut i = 0;
        loop{
            if i > game_state.player_count{
                break;
            }
            let player = get !(world, (game_id, i),Player);
            set !(world, Player{
                game_id: game_id,
                index: player.index,
                player_address: player.player_address,
                role: player.role,
                is_dead: player.is_dead,
                nick_name: player.nick_name,
                votes_num: 0
            });
            i += 1;
        };
    }


    #[external(v0)]
    impl WereWolfGameImpl of IWereWolfGame<ContractState>{
        fn init(self: @ContractState, world: IWorldDispatcher) -> u32{
            let game_id: u32 = world.uuid();
            set !(world, GameState{
                game_id: game_id,
                player_count: 0,
                is_end: false,
                is_started: false,
                winer:0
            });

            set !(world, RoundState{
                game_id: game_id,
                rounds: 0,
                day_state: 0,
            });
            return game_id;
        }

        fn join(self: @ContractState, world: IWorldDispatcher, game_id: u32, player_address: ContractAddress, nick_name: felt252) -> u32{
            let game_state: GameState = get!(world, game_id, GameState);
            let index = game_state.player_count;
            let new_player_count = index + 1;
            let mut role = 0;
            if new_player_count <= 3{
                role = 1;
            }

            set!(world, GameState{
                game_id:game_id,
                player_count: new_player_count,
                is_end:false,
                is_started:false,
                winer:game_state.winer
            });

            set!(world, Player{
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

        fn start(self: @ContractState, world: IWorldDispatcher, game_id: u32){
            let mut game_state: GameState = get!(world, game_id, GameState);
            assert(game_state.player_count >= 6, 'player count must >= 6');
            assert(!game_state.is_started, 'game already started');
            set!(world, GameState{
                game_id:game_id,
                player_count:game_state.player_count,
                is_end:game_state.is_end,
                is_started:true,
                winer:game_state.winer
            });
            set!(world, RoundState{
                game_id:game_id,
                rounds:1,
                day_state:0
            });
        }

        fn kill(self: @ContractState, world: IWorldDispatcher, game_id: u32, player_index: u32,target_index: u32){
            let game_state:GameState = get !(world, game_id, GameState);
            assert(game_state.is_started, 'game not started');
            assert(!game_state.is_end, 'game ended');
            let player: Player= get !(world, (game_id, player_index), Player);
            assert(!player.is_dead, 'player is dead');
            assert(player.role == 1, 'only wolfman can kill people');
            let target_player: Player= get !(world, (game_id, target_index), Player);
            assert(!target_player.is_dead, 'target player is dead');
            let round_state: RoundState = get !(world, game_id, RoundState);
            assert(round_state.day_state == 0, ' must kill at night');

            set !(world, Player{
                game_id: game_id,
                index: target_index,
                player_address: target_player.player_address,
                role: target_player.role,
                is_dead: true,
                nick_name: target_player.nick_name,
                votes_num: 0
            });

            let (is_end, winer) = check_game_end(world, game_id, game_state);
            is_end.print();
            winer.print();


            if !is_end{
                set!(world, RoundState{
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

        fn vote(self: @ContractState, world: IWorldDispatcher,game_id: u32, player_index: u32,target_index: u32){
            let game_state:GameState = get !(world, game_id, GameState);
            assert(game_state.is_started, 'game not started');
            assert(!game_state.is_end, 'game ended');
            let player: Player= get !(world, (game_id, player_index), Player);
            assert(!player.is_dead, 'player is dead');
            let target_player: Player= get !(world, (game_id, target_index), Player);
            assert(!target_player.is_dead, 'target player is dead');
            let round_state: RoundState = get !(world, game_id, RoundState);
            assert(round_state.day_state == 1, ' must vote at daytime');

            let vote_num = target_player.votes_num;
            let new_vote_num = vote_num + 1;
            set !(world, Player{
                game_id: game_id,
                index: target_player.index,
                player_address: target_player.player_address,
                role: target_player.role,
                is_dead: target_player.is_dead,
                nick_name: target_player.nick_name,
                votes_num: new_vote_num
            });

            let mut i:usize = 0;
            let mut total_votes: u32 = 0;
            let mut max_votes: u32 = 0;
            let mut max_voted_player_index: u32 = 0;
            let mut live_count:u32 = 0;
            loop{
                if i >= game_state.player_count{
                    break;
                }
                let player = get !(world, (game_id, i),Player);
                total_votes += player.votes_num;

                if !player.is_dead{
                    live_count += 1;
                }
                if player.votes_num > max_votes{
                    max_votes = player.votes_num;
                    max_voted_player_index = player.index;
                }
                i += 1;
            };

            // total_votes.print();
            // live_count.print();

            if total_votes == live_count{
                'vote end'.print();

                let dead_player = get!(world, (game_id, max_voted_player_index), Player);

                set !(world, Player{
                    game_id: game_id,
                    index: max_voted_player_index,
                    player_address: dead_player.player_address,
                    role: dead_player.role,
                    is_dead: true,
                    nick_name: dead_player.nick_name,
                    votes_num: 0
                });
                max_voted_player_index.print();

                roll_back_vote(world, game_id, game_state);

                let (is_end, winer) = check_game_end(world, game_id, game_state);

                if !is_end{
                    set!(world, RoundState{
                        game_id: game_id,
                        rounds: round_state.rounds,
                        day_state: 0,
                    });
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
    }
}