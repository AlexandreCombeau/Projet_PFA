open Ecs
open Component_defs
open System_defs

let create name x y w h =
  let e = Entity.create () in
  (* components *)
  Position.set e { x = x; y = y};
  Velocity.set e Vector.zero;
  Box.set e {width = w; height= h };
  Name.set e name;
  Background.set e true;
  Surface.set e (Color (Gfx.color 250 0 250 100));
  (* Systems *)
  Collision_S.register e;
  Draw_S.register e;
  e
  
let clear () = 
  let elem_list = Background.members () in
  List.iter (fun e -> 
    if (Background.get (fst e)) == false then begin 
      Position.delete (fst e);
      Velocity.delete (fst e);
      Box.delete (fst e);
      Surface.delete (fst e);
      Name.delete (fst e);
      Background.delete (fst e);
     
      Collision_S.unregister (fst e);
      Draw_S.unregister (fst e);
    end;) elem_list;
  ()