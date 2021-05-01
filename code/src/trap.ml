open Ecs
open Component_defs
open System_defs

let create name x y w h room dx dy =
  let e = Entity.create () in 
  (* components *)
  Position.set e { x = x; y = y };
  Velocity.set e Vector.zero;
  Box.set e {width = w; height= h };
  Name.set e name;
  Background.set e true;
  Before.set e true;
  Hurt.set e 1;
  Surface.set e (Color (Gfx.color 0 250 0 100));
  Destination.set e { name = room ; x = dx ; y = dy };
  (* Systems *)
  Collision_S.register e;
  Draw_S.register e;
  e