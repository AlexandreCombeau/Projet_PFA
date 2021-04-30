open Ecs
open Component_defs
open System_defs

type action = { 
                mutable move_left : bool;
                mutable move_right : bool;
                mutable jump : bool;
                mutable dash : bool;
                mutable bounce : bool;
                mutable glide : bool;
                mutable crouch : bool;
                mutable interact : bool;
              }
                
                
let action = { 
               move_left = false; 
               move_right = false ; 
               jump = false; 
               dash = false; 
               bounce = false; 
               glide = false;
               crouch = false;
               interact = false;
             }

let create name x y =
  let e = Entity.create () in
  (* components *)
  Position.set e {x = x; y = y };
  Velocity.set e { x = 0.0; y = 0.0 };
  Mass.set e 10.0;
  Box.set e {width = 32 ; height = 64};
  Surface.set e Texture.blue;
  Name.set e name;
  Resting.set e false;
  BounceRight.set e false;
  BounceLeft.set e false;
  Dash.set e false;
  Croushed.set e false;
  Before.set e false;
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
  let r = Resting.get (Game_state.get_player ()) in
  if action.interact && r then begin
    let b = Before.get (Game_state.get_player ()) in
    if b then begin
      Leaving.set (Game_state.get_level ()) true;
    end
  end else begin
    let d = Dash.get (Game_state.get_player ()) in
    let br = BounceRight.get (Game_state.get_player ()) in
    let bl = BounceLeft.get (Game_state.get_player ()) in
    let cr = Croushed.get (Game_state.get_player ()) in
    (* Si on teste r pour les mouvement horizontaux, on ne peut
       pas diriger le personnage en l'air : difficile de le contrôler
    *)
    if action.crouch && (cr == false) then begin
      Before.set (Game_state.get_player ()) false;
      let taille = Box.get (Game_state.get_player ()) in
      let pos = Position.get (Game_state.get_player ()) in
      Position.set (Game_state.get_player ()) {x = pos.x; y = pos.y +. (float_of_int taille.height)/. 2.};
      Croushed.set (Game_state.get_player ()) true;
      Box.set (Game_state.get_player ()) {width = taille.width; height = taille.height/2}
    end;
    if action.glide && (cr == false) then begin
      Before.set (Game_state.get_player ()) false;
      let v = Velocity.get (Game_state.get_player ()) in
      Velocity.set (Game_state.get_player ()) { x = v.x ; y = ((v.y)/.(1.25)) }
    end;
    if action.move_left then begin
      Before.set (Game_state.get_player ()) false;
      if (r == false) && br && action.bounce && (cr == false) then begin
        Velocity.set (Game_state.get_player ()) Vector.zero;
        move { x = 0.70 ; y = -0.25 };
        Dash.set (Game_state.get_player ()) true;
        BounceRight.set (Game_state.get_player ()) false
      end else begin
        if action.dash && d && (action.move_right == false) && (cr == false) then begin
          Velocity.set (Game_state.get_player ()) Vector.zero;
          move { x = -0.80 ; y = -0.05 };
          Resting.set (Game_state.get_player ()) false;
          Dash.set (Game_state.get_player ()) false
        end else begin 
          Resting.set (Game_state.get_player ()) false;
          BounceRight.set (Game_state.get_player ()) false;
          move { x = -0.05 ; y = 0.0 }
        end
      end
    end;
    if action.move_right then begin
      Before.set (Game_state.get_player ()) false;
      if (r == false) && bl && action.bounce && (cr == false) then begin
        Velocity.set (Game_state.get_player ()) Vector.zero;
        move { x = -0.70 ; y = -0.25 };
        Dash.set (Game_state.get_player ()) true;
        BounceLeft.set (Game_state.get_player ()) false
      end else begin
        if action.dash && d && (action.move_left == false) && (cr == false) then begin
          Velocity.set (Game_state.get_player ()) Vector.zero;
          move { x = 0.80 ; y = -0.05 };
          Resting.set (Game_state.get_player ()) false;
          Dash.set (Game_state.get_player ()) false
        end else begin
          Resting.set (Game_state.get_player ()) false;
          BounceLeft.set (Game_state.get_player ()) false;
          move { x = 0.05 ; y = 0.0 }
        end
      end
    end;
    if action.jump && r then begin
      Before.set (Game_state.get_player ()) false;
      move { x = 0.0; y = -0.35 };
      Resting.set (Game_state.get_player ()) false
    end
  end
    
let jump () = action.jump <- true
let run_left () = action.move_left <- true
let run_right () = action.move_right <- true
let dash () = action.dash <- true
let bounce () = action.bounce <- true
let glide () = action.glide <- true
let crouch () = action.crouch <- true
let interact () = action.interact <- true

let stop_jump () = action.jump <-  false
let stop_run_left () = action.move_left <- false
let stop_run_right () = action.move_right <- false
let stop_dash () = action.dash <- false
let stop_bounce () = action.bounce <- false
let stop_glide () = action.glide <- false
let stop_crouch () = 
  begin 
    action.crouch <- false;
    if Croushed.get (Game_state.get_player ()) then begin
      let taille = Box.get (Game_state.get_player ()) in
      let pos = Position.get (Game_state.get_player ()) in
      Position.set (Game_state.get_player ()) {x = pos.x; y = pos.y -. (float_of_int taille.height)};
      Croushed.set (Game_state.get_player ()) false;
      Box.set (Game_state.get_player ()) {width = taille.width; height = taille.height*2};
    end
  end
let stop_interact () = action.interact <- false