let commands = Hashtbl.create 17


let register_command ev f =
  if ev != Gfx_base.NoEvent then
    Hashtbl.add commands  ev f

let get_commands ev = Hashtbl.find_all commands ev