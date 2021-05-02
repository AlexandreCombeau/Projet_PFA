open Ecs

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
 

 
let init_game _dt =
  Level.load_level "hub";
  let player = Player.create "player" 84.0 12.0 in  
  Level.load_background "hub";
  let inventory = Inventory.create [] false false false false in
  let level = Level.create "hub" in
  Game_state.init player level inventory;
  Level.load_other "hub"; 
  Input_handler.register_command (KeyDown "w") (Player.jump);
  Input_handler.register_command (KeyUp "w") (Player.stop_jump);
  Input_handler.register_command (KeyDown "w") (Player.bounce);
  Input_handler.register_command (KeyUp "w") (Player.stop_bounce);
  Input_handler.register_command (KeyDown "c") (Player.dash);
  Input_handler.register_command (KeyUp "c") (Player.stop_dash);
  Input_handler.register_command (KeyDown "s") (Player.glide);
  Input_handler.register_command (KeyUp "s") (Player.stop_glide);
  Input_handler.register_command (KeyDown "ArrowUp") (Player.interact);
  Input_handler.register_command (KeyUp "ArrowUp") (Player.stop_interact);
  
  Input_handler.register_command (KeyDown "ArrowDown") (Player.crouch);
  Input_handler.register_command (KeyUp "ArrowDown") (Player.stop_crouch);
  Input_handler.register_command (KeyDown "ArrowLeft") (Player.run_left);
  Input_handler.register_command (KeyUp "ArrowLeft") (Player.stop_run_left);
  Input_handler.register_command (KeyDown "ArrowRight") (Player.run_right);
  Input_handler.register_command (KeyUp "ArrowRight") (Player.stop_run_right);
  System.init_all ();
  false

let play_game dt =
  Player.do_move ();
  let check = Level.check_state () in
  if check then begin 
    Level.load_view "end";
    Inventory.clear ();
    Level.load_level "end";
    let player = Player.create "player" 2.0 1.0 in
    Level.load_background "end"; 
    let inventory = Inventory.create [] false false false false in
    Level.set "end";
    Game_state.init player (Game_state.get_level ()) inventory;
    System.init_all ();
  end else begin
    let lvl = Level.change_level () in
    if lvl then begin 
      System.init_all ();
    end
  end;
  System.update_all dt;
  true


let run () =
  Gfx.main_loop
  (chain_functions [
    Loading_image.still_loading;
    init_game;
    play_game])
