open Ecs
open Component_defs
open System_defs

let create name w h =
  let e = Entity.create () in
  (* components *)
  Name.set e name;
  Position.set e { x = 0.0; y = 0.0 };
  Box.set e {width = w; height = h };
  Surface.set e Texture.cyan;
  
  Draw_S.register e;
  e