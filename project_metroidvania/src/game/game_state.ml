type turn = Playing
  | PlayerLost
  
type t = {player : Entity.t; mutable turn : turn}

let state = ref {player = Entity.dummy; turn = PlayerLost}

let get_player () = !state.player
let get_turn () = !state.turn

let play () = !state.turn <- Playing

let init pe = 
    state := { !state with player = pe}