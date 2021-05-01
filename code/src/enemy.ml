open Ecs
open Component_defs
open System_defs

type action = { 
                mutable move_left : bool;
                mutable move_right : bool;
                mutable jump : bool;
              }
                
                
let action = { 
               move_left = false; 
               move_right = false ; 
               jump = false; 
             }

let create name x y =
  let e = Entity.create () in
  (* components *)
  Position.set e {x = x; y = y };
  Velocity.set e { x = 0.0; y = 0.0 };
  Mass.set e 10.0;
  Box.set e {width = 32 ; height = 64};
  Surface.set e Texture.cyan;
  Name.set e name;
  Resting.set e false;
  Before.set e true;
  Hurt.set e 1;
  SumForces.set e Vector.zero;
  (*CollisionResolver.set e is_resting;*)
  (* systems *)
  Collision_S.register e;
  Control_S.register e;
  Move_S.register e;
  Draw_S.register e;
  Force_S.register e;
  e

let move fdir =
  let e = Game_state.get_player () in
    let old_f = SumForces.get e in
    let new_f = Vector.add fdir old_f in
    SumForces.set e new_f

let do_move () = 
  let player = (Game_state.get_player ()) in 
  let r = Resting.get player in
  (* Si on teste r pour les mouvement horizontaux, on ne peut
     pas diriger le personnage en l'air : difficile de le contrôler
  *)
  if action.move_left then begin
    Resting.set player false;
    move { x = -0.05 ; y = 0.0 }
  end;
  if action.move_right then begin
    Resting.set player false;
    move { x = 0.05 ; y = 0.0 }
  end;
  if action.jump && r then begin
    move { x = 0.0; y = -0.35 };
    Resting.set player false
  end
    
let jump () = action.jump <- true
let run_left () = action.move_left <- true
let run_right () = action.move_right <- true

let stop_jump () = action.jump <-  false
let stop_run_left () = action.move_left <- false
let stop_run_right () = action.move_right <- false