type turn = Playing | PlayerLost
val init : Entity.t -> unit
val get_turn : unit -> turn
val play : unit -> unit
val get_player : unit -> Entity.t