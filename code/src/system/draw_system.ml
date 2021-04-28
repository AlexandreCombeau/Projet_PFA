open Component_defs

let ctx = ref None
let init () =
  let _, c = Gfx.create 
  "game_canvas:800x600:" 
  in
  ctx := Some c

let update _dt el =
  let ctx = Option.get !ctx in
  let p = Position.get (Game_state.get_player ()) in 
  let b = Box.get (Game_state.get_player ()) in
  let level = Box.get (Game_state.get_level ()) in
  let xr = if p.x <  ((800.0-.(float_of_int b.width))/.2.0) then 0 
           else begin if p.x > ((float_of_int level.width)-.((800.0+.(float_of_int b.width))/.2.0))
                      then (level.width - 800)
                      else ((int_of_float (p.x+.(float_of_int b.width)/.2.0)) - 400)
                end in
  let yr = if p.y < ((600.0-.(float_of_int b.height))/.2.0) then 0
           else begin if p.y > ((float_of_int level.height)-.((600.0+.(float_of_int b.height))/.2.0))
                      then (level.height - 600)
                      else ((int_of_float (p.y+.(float_of_int b.height)/.2.0)) - 300)
                end in
  Gfx.clear_rect ctx 0 0  800 600;
  List.iter (fun e ->
    let pos = Position.get e in
    let box = Box.get e in
    let surface = Surface.get e in (* Question 3.2 *)
    match surface with
    Color color -> Gfx.fill_rect ctx ((int_of_float pos.x) - xr)
                         ((int_of_float pos.y) - yr)
                          box.width
                          box.height
                          color

                          (* Question 3.3 *)
    | Image render -> Gfx.blit_scale ctx render ((int_of_float pos.x) - xr)
                                               ((int_of_float pos.y) - yr)
                                                box.width
                                               box.height
    | Animation anim -> (* Question 4.5 *)
                let v = Velocity.get e in
                let d = if v.x < 0.0 then -1 else if v.x > 0.0 then 1 else 0 in
                let render = Texture.get_frame anim d in
                Gfx.blit_scale ctx render ((int_of_float pos.x) - xr)
                ((int_of_float pos.y) - yr) box.width box.height
    | Text (text, font, color) ->
           Gfx.draw_text ctx text ((int_of_float pos.x) - xr) ((int_of_float pos.y) - yr) font color
    ) el;
    Gfx.commit ctx
