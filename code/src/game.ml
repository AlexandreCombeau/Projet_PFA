open Ecs

let () = Loading_image.load_image "resources/images/perso/anim_course_g.png"
let () = Loading_image.load_image "resources/images/perso/anim_course_d.png"
let () = Loading_image.load_image "resources/images/perso/anim_crouch_g.png"
let () = Loading_image.load_image "resources/images/perso/anim_crouch_d.png"
let () = Loading_image.load_image "resources/images/perso/planner_g.png"
let () = Loading_image.load_image "resources/images/perso/planner_d.png"

let () = Loading_image.load_image "resources/images/world/large_floor_3.png"
let () = Loading_image.load_image "resources/images/world/large_wall_3.png"
let () = Loading_image.load_image "resources/images/world/wall_2.png"
let () = Loading_image.load_image "resources/images/world/wall_1.png"
let () = Loading_image.load_image "resources/images/world/background_2.png"

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
  Level.load_level "level1";
  let player = Player.create "player" 100.0 450.0 (Loading_image.get_image "resources/images/perso/anim_course_d.png") in
  Level.load_background "level1";
  let inventory = Inventory.create 3 [] true true false true in
  let level = Level.create "level1" in
  Game_state.init player level inventory;
  Level.load_other "level1";
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

let cpt = ref 0.0

let play_game dt =
  if (dt >= !cpt) then begin
    Player.do_move ();
    let lvl = Level.change_level () in
    if lvl then System.init_all ();
    System.update_all dt;
    cpt := !cpt +. 1000.0/.60.0;
  end;
  true


let run () =
  Gfx.main_loop
  (chain_functions [
    Loading_image.still_loading;
    init_game;
    play_game])
