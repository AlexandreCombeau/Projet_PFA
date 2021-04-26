module Make (T : sig type t val name : string end):
sig
    val set : Entity.t -> T.t -> unit
    val get : Entity.t -> T.t
    val members: unit -> (Entity.t*T.t) list
    val has_component : Entity.t -> bool
    val delete : Entity.t -> unit
    val clear : unit
end

(* Raised by get if the given entity does not have
   the associated component *)
exception MissingComponent of (Entity.t * string)