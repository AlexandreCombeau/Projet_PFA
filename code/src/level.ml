open Ecs
open Component_defs
open System_defs
    
let create name =
  let e = Entity.create () in
  (* components *)
  let size = String.split_on_char ',' (input_line (open_in ("/static/resources/"^name^"/size.txt"))) in
  Box.set e {width = (int_of_string (List.nth size 0)) ; height = (int_of_string (List.nth size 1)) };
  Leaving.set e false;
  Destination.set e { name = "level1" ; x = 100.0 ; y = 450.0 };
  Name.set e name;
  e
  
let load_walls name = 
    let ic = open_in ("/static/resources/"^name^"/walls.txt") in
    let () =
      try
        let count = ref 0 in
        while true do
            let line = input_line ic in
            match String.split_on_char ',' line with
            | [ sx; sy; sw; sh ] -> ignore (Wall.create ("wall_" ^ string_of_int !count)
                                                        (float_of_string sx)
                                                        (float_of_string sy)
                                                        (int_of_string sw)
                                                        (int_of_string sh));
                                                        count := !count + 1;
            | _ -> ()
        done;
      with End_of_file -> () in 
      ()
    
let load_doors name = 
    let ic = open_in ("/static/resources/"^name^"/doors.txt") in
    let () =
        try
          let count = ref 0 in
          while true do
            let line = input_line ic in
            match String.split_on_char ',' line with
              [ sx; sy; sw; sh; sr; sdx; sdy ] -> ignore (Door.create ("door_" ^ string_of_int !count)
                                                            (float_of_string sx)
                                                            (float_of_string sy)
                                                            (int_of_string sw)
                                                            (int_of_string sh)
                                                            sr
                                                            (float_of_string sdx)
                                                            (float_of_string sdy));
                                                            count := !count + 1;
              | _ ->  ()
            done 
          with End_of_file -> () in
          ()
  
let clear () = 
  let elem_list = Name.members () in
  List.iter (fun e -> 
    Position.delete (fst e);
    Velocity.delete (fst e);
    Mass.delete (fst e);
    Box.delete (fst e);
    Surface.delete (fst e);
    Name.delete (fst e);
    CollisionResolver.delete (fst e);
    Resting.delete (fst e);
    BounceRight.delete (fst e);
    BounceLeft.delete (fst e);
    Dash.delete (fst e);
    Croushed.delete (fst e);
    Leaving.delete (fst e);
    Before.delete (fst e);
    Background.delete (fst e);
    SumForces.delete (fst e);
    Destination.delete (fst e);  
  
    Collision_S.unregister (fst e);
    Control_S.unregister (fst e);
    Move_S.unregister (fst e);
    Draw_S.unregister (fst e);
    Force_S.unregister (fst e);) elem_list;
    ()
    
let change_level ()=
  if Leaving.get (Game_state.get_level ()) then begin
    let d = Destination.get (Game_state.get_level ()) in
    clear ();
    let level = create d.name in
    load_walls d.name;
    let player = Player.create "player" d.x d.y in
    load_doors d.name;
    Game_state.init player level;
    true
  end else false