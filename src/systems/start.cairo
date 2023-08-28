#[system]
mod start{
    use dojo::world::Context;
    use dojo_werewolf::components::{GameState};
    use dojo_werewolf::components::{RoundState};
    fn execute(ctx: Context, game_id: u32){
        let mut game_state: GameState = get!(ctx.world, game_id, GameState);
        assert(game_state.player_count >= 6, 'player count must >= 6');
        assert(!game_state.is_started, 'game already started');
        set!(ctx.world, GameState{
            game_id:game_id,
            player_count:game_state.player_count,
            is_end:game_state.is_end,
            is_started:true,
            winer:game_state.winer
        });
        set!(ctx.world, RoundState{
            game_id:game_id,
            rounds:1,
            day_state:0
        });
    }
}