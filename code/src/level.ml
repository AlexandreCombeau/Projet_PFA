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
  e
  
let set name =
  let size = String.split_on_char ',' (input_line (open_in ("/static/resources/"^name^"/size.txt"))) in
  Box.set (Game_state.get_level ()) {width = (int_of_string (List.nth size 0)) ; height = (int_of_string (List.nth size 1)) };
  Leaving.set (Game_state.get_level ()) false;
  ()
  
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
      
let load_objects name = 
    let ic = open_in ("/static/resources/"^name^"/objects.txt") in
    let () =
      try
        let count = ref 0 in
        while true do
            let line = input_line ic in
            match String.split_on_char ',' line with
            | [ sx; sy; sw; sh; sm ] -> ignore (Object.create ("object_" ^ string_of_int !count)
                                                        (float_of_string sx)
                                                        (float_of_string sy)
                                                        (int_of_string sw)
                                                        (int_of_string sh)
                                                        (float_of_string sm));
                                                        count := !count + 1;
            | _ -> ()
        done;
      with End_of_file -> () in 
      ()
    
let load_exits name = 
    let ic = open_in ("/static/resources/"^name^"/exits.txt") in
    let () =
      try
        let count = ref 0 in
        while true do
            let line = input_line ic in
            match String.split_on_char ',' line with
            |[ sx; sy; sw; sh; sr; sdx; sdy ] -> ignore (Exit.create ("exit_" ^ string_of_int !count)
                                                            (float_of_string sx)
                                                            (float_of_string sy)
                                                            (int_of_string sw)
                                                            (int_of_string sh)
                                                            sr
                                                            (float_of_string sdx)
                                                            (float_of_string sdy));
                                                            count := !count + 1;
            | _ -> ()
        done;
      with End_of_file -> () in 
      ()    

let load_traps name = 
    let ic = open_in ("/static/resources/"^name^"/traps.txt") in
    let () =
        try
          let count = ref 0 in
          let pos = (Position.get (Game_state.get_player ())) in
          while true do
            let line = input_line ic in
            match String.split_on_char ',' line with
              |[ sx; sy; sw; sh ] -> ignore (Trap.create ("trap_" ^ string_of_int !count)
                                                            (float_of_string sx)
                                                            (float_of_string sy)
                                                            (int_of_string sw)
                                                            (int_of_string sh)
                                                            name
                                                            pos.x
                                                            pos.y);
                                                            count := !count + 1;
              | _ ->  ()
            done 
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
              |[ sx; sy; sw; sh; sr; sdx; sdy ] -> ignore (Door.create ("door_" ^ string_of_int !count)
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
          
let load_items name = 
    let ic = open_in ("/static/resources/"^name^"/items.txt") in
    let () =
        try
          let stuff = Stuff.get (Game_state.get_inventory ()) in
          while true do
            let line = input_line ic in
            match String.split_on_char ',' line with
              |[ sn; sx; sy; sw; sh ] -> if (List.find_opt (fun e -> String.equal e sn) stuff) == None then
                                                  ignore (Item.create sn (float_of_string sx) (float_of_string sy) 
                                                                     (int_of_string sw) (int_of_string sh));
              | _ ->  ()
            done 
          with End_of_file -> () in
          ()

let load_level name = 
  load_walls name;
  load_objects name;
  ()

let load_background name =
  load_exits name;
  load_doors name;
  ()
  
let load_other name =
  load_traps name;
  load_items name;
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
    Hurt.delete (fst e);
  
    Collision_S.unregister (fst e);
    Control_S.unregister (fst e);
    Move_S.unregister (fst e);
    Draw_S.unregister (fst e);
    Force_S.unregister (fst e);) elem_list;
    ()

let check_state () = 
  if (HitPoints.get (Game_state.get_inventory ())) < 1 then begin 
    clear (); 
    true
  end else false
let change_level ()=
    if Leaving.get (Game_state.get_level ()) then begin
      let d = Destination.get (Game_state.get_level ()) in
      clear ();
      set d.name;
      load_level d.name;
      let player = Player.create "player" d.x d.y in
      load_background d.name;
      Game_state.init player (Game_state.get_level ()) (Game_state.get_inventory ());
      load_other d.name;
      true
    end else check_state ()