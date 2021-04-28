open Ecs
open Component_defs
open System_defs

let chain_functions f_list =
  let funs = ref f_list in
  fun dt -> match !funs with
               [] -> false
              | f :: ll ->
                 if f dt then true
                 else begin
                  funs := ll;
                  true
                 end
    
let create name =
  let e = Entity.create () in
  (* components *)
  let size = String.split_on_char ',' (input_line (open_in ("/static/resources/"^name^"/size.txt"))) in
  Box.set e {width = (int_of_string (List.nth size 0)) ; height = (int_of_string (List.nth size 1)) };
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
            [ sx; sy; sw; sh ] -> ignore (Wall.create ("wall" ^ string_of_int !count)
                                                        (float_of_string sx)
                                                        (float_of_string sy)
                                                        (int_of_string sw)
                                                        (int_of_string sh));
                                                        count := !count + 1;
            | _ ->  ()
        done
    with End_of_file -> () in
    false
    
let load_doors name = 
    let ic = open_in ("/static/resources/"^name^"/doors.txt") in
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
        with End_of_file -> () in
    false
    
let load_level name = 
  let walls = load_walls name in ()