exception MissingComponent of (Entity.t * string)

module Make (T : sig type t val name : string end) =
struct
  let elements : T.t Entity.Table.t =
    Entity.Table.create 16

  let set e v = Entity.Table.replace elements e v
  let get e = try
    Entity.Table.find elements e
  with
    Not_found -> raise (MissingComponent(e, T.name))

  let members () = Entity.Table.fold (fun k v a -> (k, v) :: a) elements []

  let has_component e = Entity.Table.mem elements e

  let delete e = Entity.Table.remove elements e
  
  let clear = Entity.Table.clear elements
  
end
