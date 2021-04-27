open Ecs
open Component_defs
open System_defs


type action = { mutable move_left : bool;
                mutable move_right : bool;
                mutable jump : bool;
                mutable dash : bool;
                mutable bounce : bool;
                mutable glide : bool;}
                
                
let action = { move_left = false; move_right = false ; jump = false; dash = false; bounce = false; glide = false;}

let create name x y =
  let e = Entity.create () in
  (* components *)
  Position.set e {x = x; y = y };
  Box.set e {width = 32 ; height = 64};
  Velocity.set e { x = 0.0; y = 0.0 };
  Mass.set e 10.0;
  Name.set e name;
  Surface.set e Texture.blue;
  Resting.set e false;
  Dash.set e false;
  BounceRight.set e false;
  BounceLeft.set e false;
  SumForces.set e Vector.zero;
  (*CollisionResolver.set e is_resting;*)
  (* systems *)
  Collision_S.register e;
  Control_S.register e;
  Move_S.register e;
  Draw_S.register e;
  Force_S.register e;
  e

let set name x y v resting sf =
  let e = Entity.create () in
  (* components *)
  Position.set e {x = x; y = y };
  Box.set e {width = 32 ; height = 64};
  Velocity.set e v;
  Mass.set e 10.0;
  Name.set e name;
  Surface.set e Texture.blue;
  Resting.set e resting;
  SumForces.set e sf;
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
  let r = Resting.get (Game_state.get_player ()) in
  let d = Dash.get (Game_state.get_player ()) in
  let br = BounceRight.get (Game_state.get_player ()) in
  let bl = BounceLeft.get (Game_state.get_player ()) in
  (* Si on teste r pour les mouvement horizontaux, on ne peut
     pas diriger le personnage en l'air : difficile de le contrôler
  *)
  if action.glide then begin
    let v = Velocity.get (Game_state.get_player ()) in
    Velocity.set (Game_state.get_player ()) { x = v.x ; y = ((v.y)/.(1.25)) }
  end;
  if action.move_left then begin
    if (r == false) && br && action.bounce then begin
      Velocity.set (Game_state.get_player ()) Vector.zero;
      move { x = 0.70 ; y = -0.25 };
      Dash.set (Game_state.get_player ()) true;
      BounceRight.set (Game_state.get_player ()) false
    end else begin
      if action.dash && d then begin
        Velocity.set (Game_state.get_player ()) Vector.zero;
        move { x = -0.80 ; y = -0.05 };
        Dash.set (Game_state.get_player ()) false
      end else move { x = -0.05 ; y = 0.0 }
    end
  end;
  if action.move_right then begin
    if (r == false) && bl && action.bounce then begin
      Velocity.set (Game_state.get_player ()) Vector.zero;
      move { x = -0.70 ; y = -0.25 };
      Dash.set (Game_state.get_player ()) true;
      BounceLeft.set (Game_state.get_player ()) false
    end else begin
      if action.dash && d then begin
        Velocity.set (Game_state.get_player ()) Vector.zero;
        move { x = 0.80 ; y = -0.05 };
        Dash.set (Game_state.get_player ()) false
      end else move { x = 0.05 ; y = 0.0 }
    end
  end;
  if action.jump && r then begin
    move { x = 0.0; y = -0.35 };
    Resting.set (Game_state.get_player ()) false
  end

let jump () = action.jump <- true
let run_left () = action.move_left <- true
let run_right () = action.move_right <- true
let dash () = action.dash <- true
let bounce () = action.bounce <- true
let glide () = action.glide <- true

let stop_jump () = action.jump <-  false
let stop_run_left () = action.move_left <- false
let stop_run_right () = action.move_right <- false
let stop_dash () = action.dash <- false
let stop_bounce () = action.bounce <- false
let stop_glide () = action.glide <- false