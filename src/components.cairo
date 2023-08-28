use starknet::ContractAddress;

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct GameState{
    #[key]
    game_id:u32,
    player_count: u32,
    is_end: bool,
    is_started: bool,
    winer: u8
}

//role 0 common people
//role 1 wolfman
#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Player{
    #[key]
    game_id: u32,
    #[key]
    index: u32,
    player_address: ContractAddress,
    role: u8,
    is_dead: bool,
    nick_name: felt252,
    votes_num: u32
}

// day_state 0 night
// day_state 1 daytime
#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct RoundState{
    #[key]
    game_id: u32,
    rounds: u32,
    day_state: u8,
}