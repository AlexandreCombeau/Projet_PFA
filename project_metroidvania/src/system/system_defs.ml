module Control_S = System.Make (Control_system)
module Draw_S = System.Make(Draw_system)
module Move_S = System.Make(Move_system)
module Collision_S = System.Make(Collision_system)

let () =
  System.register (module Draw_S);
  System.register (module Move_S);
  System.register (module Control_S);
  System.register (module Collision_S)