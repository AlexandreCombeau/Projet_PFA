open Component_defs
open System_defs

let launch e =
  match Game_state.get_turn () with 
    Playing -> ()
    | PlayerLost ->
      Velocity.set e { x = 0.0; y = 100.0 };
      Game_state.play()

let create name x y =
  let e = Entity.create () in
  Position.set e { x = x; y = y};
  Velocity.set e { x = 0.0; y = 0.0 };
  Mass.set e 5.0;
  Box.set e {width = 20; height= 20 };
  Name.set e name;
  Surface.set e Texture.green;
  Jumping.set e 100;


  (* systems *)
  Collision_S.register e;
  Control_S.register e;
  Draw_S.register e;
  Move_S.register e;
  e

let reset e x y  =
  Position.set e { x = x; y = y }

let move_right e =
    if Game_state.get_turn () == Playing then
    Velocity.set e { x = 100.0; y = (Velocity.get e).y }
  
let move_left e =
    if Game_state.get_turn () == Playing then
    Velocity.set e { x = -100.0; y = (Velocity.get e).y }
    
let jump e =
    if Game_state.get_turn () == Playing && Jumping.get e < 1 then
    (Velocity.set e { x = (Velocity.get e).x; y = -150.0 }; Jumping.set e ((Jumping.get e)+1))
    else Velocity.set e { x = (Velocity.get e).x; y = 100.0 }
    
let stopmoving e =
  Velocity.set e { x = 0.0; y = 100.0 }

let stopjumping e =
  Velocity.set e { x = (Velocity.get e).x; y = 100.0 };