open Ecs
open Component_defs
open System_defs

let create name x y w h img =
  let e = Entity.create () in
  (* components *)
  Position.set e { x = x; y = y};
  Velocity.set e Vector.zero;
  Mass.set e infinity;
  Box.set e {width = w; height=h };
  Name.set e name;
  let new_taille = Box.get e in
  Surface.set e (Texture.create_image (Loading_image.get_image img ) new_taille.width new_taille.height);
  (* Systems *)
  Collision_S.register e;
  Draw_S.register e;
  e