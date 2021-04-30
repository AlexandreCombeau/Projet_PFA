open Ecs 

type t = { 
  player : Entity.t;
  level : Entity.t;
  inventory : Entity.t;
  (* Ajouter d'autres champs : niveau courant, score, points de vie, … *)
}

let global_state = ref None

let get_state () = match !global_state with
  None -> failwith "Jeu non initialisé"
| Some s -> s

let init p lvl i = 
  global_state := Some { 
                         player = p;
                         level = lvl;
                         inventory = i
                       }

let get_player () = (get_state ()) . player
  
let get_level () = (get_state ()) . level

let get_inventory () = (get_state ()) . inventory