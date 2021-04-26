include Gfx_base
open Tsdl

type window = Sdl.window
type render = 
    Window of { render : Sdl.renderer;
            window : Sdl.window;
      }
  | Offscreen of { surface : Sdl.surface;
                   cache : (Sdl.renderer, 
                            (Sdl.texture * int)) Hashtbl.t;
                   mutable version : int; }

type color = (int * int * int * int)
type image = Sdl.surface

let initialized = ref false


let result = function
  Error (`Msg s) -> gfx_error "%s" s
  | Ok x -> x
;;

let blend r =
  result @@ Sdl.set_render_draw_blend_mode r Sdl.Blend.mode_blend

let fold1 f l =
  match l with
    [] -> None
    |r :: ll -> Some (List.fold_left f r ll)
;;

let parse_flags flags = 
  let win_flags, ren_flags =
  List.fold_left (fun ((wf, rf) as acc) f ->
    if String.length f == 0 then acc else
      if f.[0] == 'r' then (wf, f::rf)
      else if f.[0] == 'w' then (f::wf, rf)
      else acc  
  ) ([], []) flags
  in
  let win_flags = List.filter_map (fun f ->
    let open Sdl.Window in
    match f with
    | "w=fullscreen_desktop" -> Some fullscreen_desktop
    | "w=opengl" -> Some opengl
    | "w=shown" -> Some shown
    | "w=hidden" -> Some hidden
    | "w=borderless" -> Some borderless
    | "w=resizable" -> Some resizable
    | "w=minimized" -> Some minimized
    | "w=maximized" -> Some maximized
    | "w=input_grabbed" -> Some input_grabbed
    | "w=input_focus" -> Some input_focus
    | "w=mouse_focus" -> Some mouse_focus
    | "w=foreign" -> Some foreign
    | "w=allow_highdpi" -> Some allow_highdpi
    | "w=mouse_capture" -> Some mouse_capture
    | "w=always_on_top" -> Some always_on_top
    | "w=utility" -> Some utility
    | "w=popup_menu" -> Some popup_menu
    | "w=vulkan" -> Some vulkan
    | _ -> None  
  ) win_flags in
  let ren_flags = List.filter_map (fun f ->
      let open Sdl.Renderer in
      match f with
      | "r=software" -> Some software
      | "r=accelerated" -> Some accelerated
      | "r=presentvsync" -> Some presentvsync
      | "r=targettexture" -> Some targettexture
      | _ -> None

    ) ren_flags in
    (fold1 (Sdl.Window.(+)) win_flags, fold1 (Sdl.Renderer.(+)) ren_flags)



let create s = 
  if not !initialized then begin
      result @@ Sdl.(init Init.everything); 
      initialized := true
  end;
  let title, w, h, flags = parse_window_spec s in
  let w_flags, r_flags = parse_flags flags in
  let w_flags = match w_flags with None -> Sdl.Window.input_focus | Some f -> f in
  let window = result @@ Sdl.create_window title ~w ~h w_flags in
  let render = result @@
      match r_flags with
      None -> Sdl.create_renderer window
    | Some flags -> Sdl.create_renderer ~flags window
  in
      blend render;
      window,Window { window; render}
  ;;

let create_offscreen w h =
  let surface = result @@ 
    Sdl.create_rgb_surface_with_format ~w ~h
    ~depth:32
    Sdl.Pixel.format_argb8888
  in
  Offscreen { surface; version = 0; cache = Hashtbl.create 16 }


let render_size r =
  match r with
  Window w ->
      result @@ Sdl.get_renderer_output_size w.render
    | Offscreen s -> 
    Sdl.get_surface_size s.surface
let render_width r = fst @@ render_size r
let render_height r = snd @@ render_size r


let get_texture render surface cache version =
  try 
    Hashtbl.find cache render
  with
    Not_found ->
      let txt = result @@ Sdl.create_texture_from_surface
        render surface
      in
      let res = txt, version in
      Hashtbl.add cache render res; res

let clear_cache cache =
  Hashtbl.iter (fun _ (txt,_) ->
    Sdl.destroy_texture txt
    ) cache;
  Hashtbl.clear cache

let blit_full rdst rsrc sx sy sw sh dx dy dw dh =
  let src = Sdl.Rect.create ~x:sx ~y:sy ~w:sw ~h:sh in
  let dst = Sdl.Rect.create ~x:dx ~y:dy ~w:dw ~h:dh in
  match rdst, rsrc with
  Offscreen s1, Offscreen s2 ->
      result @@ 
       Sdl.blit_scaled ~src:s2.surface 
        (Some src) ~dst:s1.surface (Some dst);
        let nv = (s1.version + 1) land 0xfffff in
        if nv == 0 then clear_cache s1.cache;
        s1.version <- nv
  | Window w, Offscreen s ->
    let (_, version) as res = get_texture w.render s.surface s.cache s.version in
    let txt, _ =
      if version != s.version then begin
        Hashtbl.remove s.cache w.render;
        get_texture w.render s.surface s.cache s.version
      end
    else res
    in
    result @@ Sdl.render_copy ~src ~dst w.render txt 
  | _ -> gfx_error "%s"  "Unsupported blit operation"
   

let blit_scale rdst rsrc dx dy dw dh =
  let sw, sh = render_size rsrc in
  blit_full rdst rsrc 0 0 sw sh dx dy dw dh

let blit rdst rsrc dx dy =
  let sw, sh = render_size rsrc in
  blit_full rdst rsrc 0 0 sw sh dx dy sw sh

let color r g b a = (r,g,b,a)


let fill_rect render x y w h c =
  let r, g, b, a = c in
  let rect = Some (Sdl.Rect.create ~x ~y ~w ~h) in
  match render with
  Window win -> 
  result @@ Sdl.set_render_draw_color win.render 
   r g b a;
    result @@ 
     Sdl.render_fill_rect win.render rect
  |Offscreen s -> 
    let nv = (s.version + 1) land 0xfffff in
    if nv == 0 then clear_cache s.cache;
    s.version <- nv;
    let frm = result @@ Sdl.alloc_format Sdl.Pixel.format_rgba8888 in
    result @@
      Sdl.fill_rect s.surface rect 
      (Sdl.map_rgba frm r g b a);
    Sdl.free_format frm

let clear_rect render x y w h =
    fill_rect render x y w h (255, 255, 255, 255)

let load_image path =
  match
    Tsdl_image.Image.load path
  with
    Some i -> i
    | None -> gfx_error "Cannot open image %s" path
let image_ready _ = true

let image_surface isrc = Offscreen {
  surface = isrc;
  cache = Hashtbl.create 16;
  version = 0
}
let draw_image rdst isrc x y =
  blit rdst (image_surface isrc) x y

let draw_image_scale rdst isrc dx dy dw dh =
  blit_scale rdst (image_surface isrc) dx dy dw dh
  
let draw_image_full rdst isrc sx sy sw sh dx dy dw dh =
  blit_full rdst (image_surface isrc) sx sy sw sh dx dy dw dh
  

let font_cache = Hashtbl.create 17


let get_font f =
  try Hashtbl.find font_cache f with
  Not_found ->
    try
      Scanf.sscanf f "%[^:]:%d" (fun name size ->
        let font = result @@ Tsdl_ttf.Ttf.open_font name size in
        Hashtbl.replace font_cache f font; font      
      )
    with
    Scanf.Scan_failure msg ->
      begin match String.split_on_char ':' msg with
        _::_::l -> gfx_error "Invalid font spec `%s` : %s" f (String.concat "" l)
        | _ ->  gfx_error "Invalid font spec `%s`" f
      end
    | End_of_file  -> gfx_error "Invalid font spec `%s`" f


let draw_text render txt x y f (r,g,b, a) =
  if not (Tsdl_ttf.Ttf.was_init ()) then
    result @@ Tsdl_ttf.Ttf.init ();
  let font = get_font f in
  let col = Sdl.Color.create ~r ~g ~b ~a in
  let img = result @@ 
      Tsdl_ttf.Ttf.render_text_blended font txt col 
  in
  draw_image render img x y


let measure_text _ txt fnt =
   fst @@ result @@
    Tsdl_ttf.Ttf.size_utf8 (get_font fnt) txt 

let get_key ev =
  String.lowercase_ascii @@ 
    Sdl.get_key_name Sdl.Event.(get ev keyboard_keycode) 
  
let running = ref true
let poll_event () =
  let ev = Sdl.Event.create () in
    if Sdl.poll_event (Some ev) then
       let et =  Sdl.Event.(get ev typ) in
        match Sdl.Event.enum et with
          `Key_down -> Gfx_base.KeyDown (get_key ev)
          | `Key_up -> Gfx_base.KeyUp (get_key ev)
          | `Window_event when Sdl.Event.(get ev window_event_id
            = window_event_close
            )  -> running := false;
              Gfx_base.NoEvent
        | _ ->
          Gfx_base.NoEvent
    else
      Gfx_base.NoEvent
  
let fps = 60.0
let frame_time = 1000.0 /. fps
let main_loop f =
  let rec loop flast count tref =
    let ticks = Int32.to_float @@ Sdl.get_ticks () in
      let dtr = ticks -. tref in
      let count, tref =
        if dtr > 5000.0 then begin
          Printf.eprintf "FPS: %d %f = %f\n%!" 
          count
          dtr
          (1000. *. float count /. dtr);
          0, ticks
        end
        else (count+1, tref)
      in
      let res =  f ticks  in
      if res && !running then
        let dt = ticks -. flast in
        if dt < frame_time then
          Sdl.delay (Int32.of_float (frame_time -. dt));
        loop  ticks count tref
  in
  loop 0.0 0 0.0

let commit r = match r with
    Window w -> Sdl.render_present w.render
    | _ -> ()

let debug msg =
  output_string stderr msg;
  flush stderr