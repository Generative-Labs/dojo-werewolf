#[system]
mod init{
    use dojo::world::Context;
    use dojo_werewolf::components::{GameState};
    use dojo_werewolf::components::{RoundState};
    fn execute(ctx: Context) -> u32{
        let game_id: u32 = ctx.world.uuid();
        set !(ctx.world, GameState{
            game_id: game_id,
            player_count: 0,
            is_end: false,
            is_started: false,
            winer:0
        });

        set !(ctx.world, RoundState{
            game_id: game_id,
            rounds: 0,
            day_state: 0,
        });
        return game_id;
    }
}
