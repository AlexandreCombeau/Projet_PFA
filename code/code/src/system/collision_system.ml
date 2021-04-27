open Component_defs

let init () = ()

(*let load e1 e2 v =
    let name = Name.get e1
    in let r = Resting.get e1
    in let sf = SumForces.get e1

    in let d = Destination.get e2

    in Level.load_room d.roomID
    Player.set name d.x d.y v r sf *)

let update _dt el =
  List.iteri (fun i e1 ->
    List.iteri (fun j e2 ->
      (* Une double boucle qui évite de comparer deux fois
         les objets : si on compare A et B, on ne compare pas B et A.
         Il faudra améliorer cela si on a beaucoup (> 30) objets simultanément.
      *)
      if j > i then begin
        (* les composants du rectangle r1 *)
        let pos1 = Position.get e1 in
        let box1 = Box.get e1 in
        (* les composants du rectangle r2 *)
        let pos2 = Position.get e2 in
        let box2 = Box.get e2 in
        (* les vitesses *)
        let v1 = Velocity.get e1 in
        let v2 = Velocity.get e2 in
        (* [1] la soustraction de Minkowski *)
        let s_pos, s_rect = Rect.mdiff pos2 box2 pos1 box1 in
        (* [2] si intersection et un des objets et mobile, les objets rebondissent *)
        if Rect.has_origin s_pos s_rect &&
          not (Vector.is_zero v1 && Vector.is_zero v2)
          then begin
                        (* [3] le plus petit des vecteurs a b c d *)
                        let a = Vector.{ x = s_pos.x; y = 0.0} in
                        let b = Vector.{ x = float s_rect.width +. s_pos.x; y = 0.0 } in
                        let c = Vector.{ x = 0.0; y = s_pos.y } in
                        let d = Vector.{ x = 0.0; y = float s_rect.height +. s_pos.y} in 
                        let n = List.fold_left (fun min_v v ->
                          if Vector.norm v  < Vector.norm min_v then v else min_v) 
                          d [a ; b; c]
                        in
                        (*  [4] rapport des vitesses et déplacement des objets *)
                        let n_v1 = Vector.norm v1 in
                        let n_v2 = Vector.norm v2 in
                        let s = (n_v1 +. n_v2) in
                        let n1 = n_v1 /. s in
                        let n2 = n_v2 /. s in
                        let delta_pos1 = Vector.mult n1 n in
                        let delta_pos2 = Vector.mult (Float.neg n2) n in
                        Position.set e1 (Vector.add pos1 delta_pos1);
                        Position.set e2 (Vector.add pos2 delta_pos2);
                        if Resting.has_component e1 then Resting.set e1 (n == c);
                        if Resting.has_component e2 then Resting.set e2 (n == c);
                        if BounceLeft.has_component e1 then BounceLeft.set e1 (n == a && n != c);
                        if BounceLeft.has_component e2 then BounceLeft.set e2 (n == a && n != c);
                        if BounceRight.has_component e1 then BounceRight.set e1 (n == b && n != c);
                        if BounceRight.has_component e2 then BounceRight.set e2 (n == b && n != c);
                        if Dash.has_component e1 then Dash.set e1 (n == c);
                        if Dash.has_component e2 then Dash.set e2 (n == c);

                         (* [10] appel des resolveurs *)
                         if CollisionResolver.has_component e1 then (CollisionResolver.get e1) e1 e2;
                         if CollisionResolver.has_component e2 then (CollisionResolver.get e2) e2 e1;

                        (* [5] On normalise n (on calcule un vecteur de même direction mais de norme 1) *)
                        let n = Vector.normalize n in
                        (* [6] Vitesse relative entre v2 et v1 *)
                        let v = Vector.sub v1 v2 in

                        (* Préparation au calcul de l'impulsion *)
                        (* Elasticité fixe. En pratique, l'elasticité peut être stockée dans
                           les objets comme un composant : 1 pour la balle et les murs, 0.5 pour
                           des obstacles absorbants, 1.2 pour des obstacles rebondissant, … *)
                        let e = 0.0 in

                        (* normalisation des masses *)
                        let m1 = Mass.get e1 in
                        let m2 = Mass.get e2 in    
                        let m1, m2 = 
                          if Float.is_infinite m1 && Float.is_infinite m2 then
                            if n_v1 = 0.0 then m1, 1.0 else if n_v2 = 0.0 then 1.0, m2 else
                              0.0, 0.0
                            else
                              m1, m2
                        in
                        (* [7] calcul de l'impulsion *)
                        let j =
                           (-.(1.0 +. e) *. Vector.dot v n)/. ( (1. /. m1) +. (1. /. m2))
                        in
                        (* [8] calcul des nouvelles vitesses *)
                        let new_v1 = Vector.add v1 (Vector.mult (j/. m1) n) in
                        let new_v2 = Vector.sub v2 (Vector.mult (j/. m2) n) in
                        (* [9] mise à jour des vitesses *)
                        Velocity.set e1 new_v1;
                        Velocity.set e2 new_v2;
                  end
      end
      ) el) el
