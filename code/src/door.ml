open Ecs
open Component_defs
open System_defs

let create name x y w h room dx dy =
  let e = Entity.create () in
  (* components *)
  Position.set e { x = x; y = y};
  Velocity.set e Vector.zero;
  Mass.set e 1.0;
  Box.set e {width = w; height=h };
  Name.set e name;
  Surface.set e Texture.yellow;
  Destination.set e { roomID = room ; x = dx ; y = dy };
  (* Systems *)
  Collision_S.register e;
  Draw_S.register e;
  e