open Ecs
open Component_defs
open System_defs

let create health st g sh r c =
  let e = Entity.create () in
  (* components *)
  HitPoints.set e health;
  Stuff.set e st;
  Glider.set e g;
  Shrinker.set e sh;
  Reactor.set e r;
  Climber.set e c;
  e