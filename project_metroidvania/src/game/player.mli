val create : string -> float -> float -> Entity.t
val reset : Entity.t -> float -> float -> unit

val move_right : Entity.t -> unit
val move_left : Entity.t -> unit
val jump : Entity.t -> unit
val stopjumping : Entity.t -> unit
val stopmoving : Entity.t -> unit

val launch : Entity.t -> unit