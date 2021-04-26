open Ecs
open Component_defs
open System_defs

let create name x y w h m =
  let e = Entity.create () in
  (* components *)
  Position.set e {x = x; y = y };
  Box.set e {width = w ; height = h};
  Velocity.set e { x = 0.0; y = 0.0 };
  Mass.set e m;
  Name.set e name;
  Surface.set e Texture.yellow;
  SumForces.set e Vector.zero;
  (*CollisionResolver.set e is_resting;*)
  (* systems *)
  Collision_S.register e;
  Move_S.register e;
  Draw_S.register e;
  Force_S.register e;
  e