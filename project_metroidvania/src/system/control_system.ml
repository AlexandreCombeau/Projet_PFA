let init () = ()

let update _dt _el =
  (* Check for keyboard events *)
  let rec loop_events () =
      match Gfx.poll_event () with
     NoEvent -> ()
    | ev -> 
      List.iter (fun f -> f ()) (Input_handler.get_commands ev);
      loop_events ()
    in
    loop_events ()