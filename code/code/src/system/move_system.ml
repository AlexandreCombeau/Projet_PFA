open Component_defs

let init () = ()

let time = ref 0.0
let update dt el =
  let delta_t = dt -. !time in
  time := dt;
  List.iter (fun e ->
    let pos = Position.get e in
    let speed = Vector.mult delta_t (Velocity.get e) in
    if not (Vector.is_zero speed) then
      (* On évite de mettre à jour les objets qui ne bougent pas *)
      Position.set e ({ x = pos.x +. speed.x; y = pos.y +. speed.y })
    ) el
