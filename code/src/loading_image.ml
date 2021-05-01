open Ecs

let image_storage = Hashtbl.create 50
let load_image s = Hashtbl.add image_storage s (Gfx.load_image s)
let get_image s = Hashtbl.find image_storage s
  
let still_loading _dt = 
  not (Hashtbl.fold (fun _ img acc -> acc && Gfx.image_ready img) image_storage true)
