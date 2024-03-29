open Ecs
open Component_defs
open System_defs

let create name x y w h m =
  let e = Entity.create () in
  (* components *)
  Position.set e { x = x; y = y};
  Velocity.set e Vector.zero;
  Mass.set e m;
  Box.set e {width = w; height=h };
  Name.set e name;
  Surface.set e Texture.yellow;
  (* Systems *)
  Collision_S.register e;
  Draw_S.register e;
  e
