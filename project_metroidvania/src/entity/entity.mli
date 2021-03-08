type t

val create : unit -> t
val pp : Format.formatter -> t -> unit
val hash : t -> int
val equal : t -> t -> bool
val compare : t -> t -> int

val dummy : t

module Table : Hashtbl.S with type key = t