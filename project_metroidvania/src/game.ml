(* All our objects *)

let player = Player.create "player" Globals.player_init_x Globals.player_init_y
let wall_bottom = Wall.create "wall_bottom" 0.0 580.0 (Globals.canvas_width) (Globals.wall_thickness)
let wall_left = Wall.create "wall_left" 0.0 20.0 (Globals.wall_thickness) ((Globals.canvas_height-40))
let wall_rght = Wall.create "wall_right" 780.0 20.0 (Globals.wall_thickness) ((Globals.canvas_height-40))
let wall_top = Wall.create "wall_top" 0.0 0.0 (Globals.canvas_width) (Globals.wall_thickness)
let platform = Wall.create "platform" 375.0 525.0 50 10
let objet = Object.create "objet" 375.0 400.0

let () =
  Input_handler.register_command (KeyDown "ArrowRight") (fun () -> Player.move_right player);
  Input_handler.register_command (KeyDown "ArrowLeft") (fun () -> Player.move_left player);
  Input_handler.register_command (KeyDown "w") (fun () -> Player.jump player);
  Input_handler.register_command (KeyUp "ArrowRight") (fun () -> Player.stopmoving player);
  Input_handler.register_command (KeyUp "ArrowLeft") (fun () -> Player.stopmoving player);
  Input_handler.register_command (KeyUp "w") (fun () -> Player.stopjumping player);
  
  Input_handler.register_command (KeyDown "n") (fun () -> Player.launch player);

  Game_state.init player

(* *)
let init () = System.init_all ()

let frames = ref 0
let time = ref 0.0
let update dt =
  if !frames mod 600 == 0 then begin
    let t = dt -. !time in
    Gfx.debug (Format.asprintf "%f fps" (1000. *. float !frames /. t));
    time := dt;
    frames := 0
  end;
  incr frames;
  (* Update all systems *)
  System.update_all dt;
  (* Repeat indefinitely *)
  true

let update_loop () = Gfx.main_loop update

let () =
  init ();
  update_loop ()