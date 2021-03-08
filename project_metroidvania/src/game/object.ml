open Component_defs
open System_defs

let walls = Entity.Table.create 17

let create name x y w h =
  let e = Entity.create () in
  Entity.Table.add walls e () ;
  (* components *)
  Position.set e { x = x; y = y};
  Velocity.set e { x = 0.0; y = 100.0 };
  Mass.set e 5.0;
  Box.set e {width = w; height= h};
  Name.set e name;
  Surface.set e Texture.yellow;

  (* Systems *)
  Collision_S.register e;
  Draw_S.register e;
  e
let _is_wall e = Entity.Table.mem walls e