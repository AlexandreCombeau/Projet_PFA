open Component_defs

let ctx = ref None
let init () =
  let _, c = Gfx.create "canvas"  in
  ctx := Some c

let update _dt el =
  let ctx = Option.get !ctx in
  Gfx.clear_rect ctx 0 0 800 600;
  List.iter (fun e ->
    let pos = Position.get e in
    let box = Box.get e in
    let color = Surface.get e in
    Gfx.fill_rect ctx (int_of_float pos.x)
                         (int_of_float pos.y)
                          box.width
                          box.height
                          color;
    ) el