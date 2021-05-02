open Ecs
open Component_defs
open System_defs

let create st g sh r c =
  let e = Entity.create () in
  (* components *)
  Stuff.set e st; 
  Glider.set e g;
  Shrinker.set e sh;
  Reactor.set e r; 
  Climber.set e c;
  e
  
let clear () = 
  let elem_list = Stuff.members () in
  List.iter (fun e -> 
    Stuff.delete (fst e);
    Glider.delete (fst e);
    Shrinker.delete (fst e); 
    Reactor.delete (fst e);
    Climber.delete (fst e);) elem_list;
    ()