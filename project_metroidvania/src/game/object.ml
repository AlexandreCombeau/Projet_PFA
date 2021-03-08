open Component_defs
open System_defs

let create name x y =
  let e = Entity.create () in
  (* components *)
  Position.set e {x = x; y = y };
  Box.set e {width = 20 ; height = 20};
  Velocity.set e { x = 0.0; y = 100.0 };
  Mass.set e 25.0;
  Name.set e name;
  (* Question 4.6 *)
  Surface.set e Texture.yellow;

  (* systems *)
  Collision_S.register e;
  Control_S.register e;
  Move_S.register e;
  Draw_S.register e;
  e

let reset e x y  =
  Velocity.set e { x = 0.0; y = 100.0 };
  Position.set e { x = x; y = y}