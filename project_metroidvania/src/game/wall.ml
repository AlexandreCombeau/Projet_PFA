open Component_defs
open System_defs

let walls = Entity.Table.create 17

let create name x y w h =
  let e = Entity.create () in
  Entity.Table.add walls e () ;
  (* components *)
  Position.set e { x = x; y = y};
  Velocity.set e Vector.zero;
  Mass.set e infinity;
  Box.set e {width = w; height= h};
  Name.set e name;
  Surface.set e Texture.black;

  (* Systems *)
  Collision_S.register e;
  Draw_S.register e;
  e
let _is_wall e = Entity.Table.mem walls e