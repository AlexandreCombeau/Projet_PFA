open Component_defs

let init () = ()

let time = ref 0.0
let update dt el =
  let delta_t = min (1. /. 60.) (1000. *.(dt -. !time)) in
  time := dt;
  List.iter (fun e ->
    let pos = Position.get e in
    let speed = Vector.mult delta_t (Velocity.get e) in
    Position.set e ({ x = pos.x +. speed.x; y = pos.y +. speed.y })
    ) el