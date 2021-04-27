open Ecs 

type t = { 
  player : Entity.t; 
  (* Ajouter d'autres champs : niveau courant, score, points de vie, … *)
}

let global_state = ref None

let get_state () = match !global_state with
  None -> failwith "Jeu non initialisé"
| Some s -> s

let init e = 
  global_state := Some { player = e }


  let get_player () = (get_state ()) . player