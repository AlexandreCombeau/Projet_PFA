open Js_of_ocaml


type window = Dom_html.canvasElement Js.t
type render = Dom_html.canvasRenderingContext2D Js.t
type color = string

let events = Queue.create ()
let create s =
  match Dom_html.getElementById_coerce s Dom_html.CoerceTo.canvas with
     None -> raise (Gfx_base.GfxError ("Gfx_js: cannot find canvas with id " ^ s))
   | Some canvas ->
      let ctx = canvas ##getContext Dom_html._2d_ in
      canvas ##. onkeydown := Dom_html.handler (fun e ->
        Js.Optdef.iter e ##.key (fun k -> 
          Queue.add (Gfx_base.KeyDown (Js.to_string k)) events);
        Js._true);
      canvas ##. onkeyup := Dom_html.handler (fun e ->
        Js.Optdef.iter e ##.key (fun k -> 
          Queue.add (Gfx_base.KeyUp (Js.to_string k)) events);
        Js._true);
      (canvas, ctx)

let create_offscreen w h =
  let canvas = Dom_html.createCanvas Dom_html.document in
    canvas ##. height := h;
    canvas ##. width := w;
    canvas##getContext Dom_html._2d_

let render_width (ctx : render) =
  ctx ##. canvas ##. width
    
let render_height (ctx : render) =
  ctx ##. canvas ##. width
    

let blit (dst : render) (src : render) x y =
  dst ## drawImage_fromCanvas (src ##. canvas) (float x) (float y)

let blit_scale (dst : render) (src : render) dx dy dw dh =
    dst ## drawImage_fromCanvasWithSize (src ##. canvas)
     (float dx) (float dy) (float dw) (float dh)

let blit_full (dst : render) (src : render) sx sy sw sh dx dy dw dh =
    dst ## drawImage_fullFromCanvas (src ##. canvas)
    (float sx) (float sy) (float sw) (float sh)
    (float dx) (float dy) (float dw) (float dh)
  
let color r g b a = 
  "rgba(" ^ string_of_int r ^ ", " ^
            string_of_int g ^ ", " ^
            string_of_int b ^ ", " ^
            string_of_float (float a /. 255.) ^ "0)" (* work around:
            Ocaml generates the literal for string_of_float (1.0) "1.",
            which is not supported by the rgba syntax. It's always safe
            to add a trainling 0 in this case, since the number is either:
            0. → 0.0
            1. -> 1.0
            0.2423 -> 0.24230
*)
let clear_rect (ctx : render) x y w h = 
  ctx ## clearRect (float x) (float y) (float w) (float h)

let fill_rect (ctx : render) x y w h c =
  (* Firebug.console ## log (Js.string c); *)
    ctx ##. fillStyle := Js.string c;
    ctx ## fillRect (float x) (float y) (float w) (float h)

type image = Dom_html.imageElement Js.t

let load_image src =
  let img = Dom_html.createImg Dom_html.document in
  img ##.src := Js.string src;
  img

let image_ready img =
  Js.to_bool img ##.complete

let draw_image (ctx : render) img x y =
  ctx ## drawImage img (float x) (float y)
  
let draw_image_scale (ctx : render) img dx dy dw dh =
  ctx ## drawImage_withSize img  (float dx) (float dy) (float dw) (float dh)
  
let draw_image_full (ctx : render) img sx sy sw sh dx dy dw dh =
  ctx ## drawImage_full img 
  (float sx) (float sy) (float sw) (float sh)
  (float dx) (float dy) (float dw) (float dh)

let draw_text (ctx : render) text x y font =
  ctx ##. font := Js.string font;
  ctx ## fillText (Js.string text) (float x) (float y)

let poll_event () =
  if Queue.is_empty events then Gfx_base.NoEvent
  else Queue.pop events

let main_loop f =
  let cb = ref (Js.wrap_callback (fun _ -> ())) in
  let loop dt =
      if f dt then
        ignore (Dom_html.window ## requestAnimationFrame (!cb))
  in
  cb := Js.wrap_callback loop;
  ignore (Dom_html.window ## requestAnimationFrame !cb)

let debug msg =
  Firebug.console ## log (Js.string msg)