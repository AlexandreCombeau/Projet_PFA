# Game

Cette archive contient un sequelette permetant de faire le projet de PFA en suivant le modèle ECS.


## Structure des répertoires 

* `resources` : répertoire dans lequel déposer les resources (images, polices, fichiers textes, …)
* `lib`: répertoire contenant deux bibliothèques :
	- `ecs`: La bibliothèque ECS telle qu'utilisée en TP. Elle définit les trois modules `Entity`, `Component` et `System`.
	- `gfx` : La bibliothèque Graphique avec un backend Javascript et un backend [SDL2](https://www.libsdl.org/)

* `src` : le répertoire devant contenir les sources du jeu. On peut suivre le même modèle que pour le jeu `pong`, en utilisant la bibliothèque ECS plutôt que d'avoir les fichiers inclus dans les sources :
 Pour l'utiliser cette bibliothèque depuis le jeu :
```
   open Ecs
   let id = Entity.create () in (* création d'une entité … *)
   ...
```
Pour les composants:
```
   (* fichier component_defs.ml *)
   open Ecs
   (* ne pas oublier de recréer ou copier le module vector.ml du jeu pong *)
   module Pos = Component.Make(struct type t = Vector.t let name = "position" end)
   …
```

Pour les systèmes:
```
(* fichier system_defs.ml
  open Ecs
  (* ne pas oublier de recréer ou copier le module draw_system.ml du jeu pong *)
  module Draw_S = System.Make(Draw_system) 
  …
  let () =
	  System.register (module Draw_S)
```
Évidement, il faut adapter les systèmes et composant à son type de jeu.
On s'attend à ce que dans le répertoire `src` se trouve un fichier `game.ml` possédant une fonction `run`, qui est le point d'entrée du programme.

*`prog`: un répertoire contenant deux programmes principaux. Ils sont uniquement là pour servir de cible de compilation différente : `game_js.ml` produit le fichier `game_js.bc.js` qui est inclus depuis le fichier `index.html`. C'est le « programme principal » compilé en Javascript, le seul que l'on demande de supporter pour le projet. `game_sdl.ml` produit le fichier `game_sdl.exe` qui utilise la bibliothèque SDL pour faire un rendu graphique et produit un exécutable natif.  Chacun de ces deux fichiers se contente d'appeler `Game.run()`. On pourra, si on le souhaite, modifier cette fonction run pour prendre en argument des arguments spécifiques au backend.

## Construction du jeu 

Il suffit de faire `dune build` à la racine. La cible construite par défaut est `_build/default/prog/game_js.bc.js` qui est incluse dans le fichier HTML `index.html`


##  Dépendences
Comme pour `pong`, le projet de base requiert `ocaml`, `js_of_ocaml`, `js_of_ocaml-ppx`, `dune`. La production de code natif (testé uniquement sous Linux pour l'instant) requiert `tsdl`, `tsdl-image` et `tsdl-ttf`.





