open Ecs
open Component_defs
open System_defs

let create name x y room dx dy =
  let e = Entity.create () in
  (* components *)
  Position.set e {x = x; y = y };
  Box.set e {width = 20 ; height = 20};
  Velocity.set e { x = 0.0; y = -1.0 };
  Mass.set e 100.0;
  Name.set e name;
  Hurt.set e 1;
  Surface.set e Texture.green;
  Destination.set e { name = room ; x = dx ; y = dy };

  (* systems *)
  Collision_S.register e;
  Control_S.register e;
  Move_S.register e;
  Draw_S.register e;
  e