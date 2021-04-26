open Ecs
open Component_defs
open System_defs
                 
let load_walls path = 
    let ic = open_in path in
    let () =
    try
        let count = ref 0 in
        while true do
            let line = input_line ic in
            match String.split_on_char ',' line with
            [ sx; sy; sw; sh ] -> ignore (Wall.create ("wall" ^ string_of_int !count)
                                                        (float_of_string sx)
                                                        (float_of_string sy)
                                                        (int_of_string sw)
                                                        (int_of_string sh));
                                                        count := !count + 1;
            | _ ->  ()
        done
    with End_of_file -> ()
    in
false
    
let load_objects path = 
    let ic = open_in path in
    let () =
    try
        let count = ref 0 in
        while true do
            let line = input_line ic in
            match String.split_on_char ',' line with
            [ sx; sy; sw; sh; sm ] -> ignore (Object.create ("object" ^ string_of_int !count)
                                                        (float_of_string sx)
                                                        (float_of_string sy)
                                                        (int_of_string sw)
                                                        (int_of_string sh)
                                                        (float_of_string sm));
                                                        count := !count + 1;
            | _ ->  ()
        done
    with End_of_file -> ()
    in
    false

let load_doors path = 
    let ic = open_in path in
    let () =
    try
        let count = ref 0 in
        while true do
            let line = input_line ic in
            match String.split_on_char ',' line with
            [ sx; sy; sw; sh; sr; sdx; sdy ] -> ignore (Door.create ("door" ^ string_of_int !count)
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
    with End_of_file -> ()
    in
    false
    
let load_room _dt room = 
    Position.clear;
    Velocity.clear;
    Mass.clear;
    Box.clear;
    Surface.clear;
    Name.clear;
    CollisionResolver.clear;
    Owner.clear;
    Resting.clear;
    SumForces.clear;
    Destination.clear;

    Control_S.clear;
    Draw_S.clear;
    Move_S.clear;
    Collision_S.clear;
    Force_S.clear;
    
    load_walls ("/static/files/"^room^"/walls.txt");
    load_objects ("/static/files/"^room^"/objects.txt");
    load_doors ("/static/files/"^room^"/doors.txt");
    
   