module type S =
sig
  val init : unit -> unit
  (* initializes the system *)

  val update : float -> unit
  (* updates the system. The float argument is the current time in nanoseconds *)

  val register : Entity.t -> unit
  (* register an entity for this system *)

  val unregister : Entity.t -> unit
  (* remove an entity from this system *)

end

module Make (T : sig val init : unit -> unit val update : float -> Entity.t list -> unit end) : S =
struct
  let elem_list = ref []
  let elem_table = Entity.Table.create 16
  let register e =
    if not (Entity.Table.mem elem_table e) then begin
      Entity.Table.add elem_table e ();
      elem_list := e :: !elem_list
    end

  let unregister e =
    Entity.Table.remove elem_table e;
    elem_list := List.filter (fun x -> x <> e) !elem_list

  let init () = T.init ()
  let update dt =
    T.update dt !elem_list
end

let systems = ref []

let register m =
  systems := m :: !systems

let init_all () =
  List.iter (fun m ->
    let module M = (val m : S) in
    M.init ()
    ) !systems
let update_all dt =
    List.iter (fun m ->
      let module M = (val m : S) in
      M.update dt
      ) !systems