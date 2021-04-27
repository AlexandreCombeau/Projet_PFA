open Component_defs
let init () = ()

let last_dt = ref 0.0 
let update dt el =
  (* Combien de temps depuis la dernière update ? *)
  let delta = dt -. !last_dt in
  last_dt := dt;

  let g = Vector.{ x = 0.0; y = 0.001 } in 
  List.iter (fun e -> 
    (*
      Somme des forces = masse * accéleration
      vitesse = accéleration * temps 
      vitesse = forces/masse * temps
    *)
    let old_v = Velocity.get e in
    let mass = Mass.get e in 
    let forces = SumForces.get e in
    let forces = Vector.add forces (Vector.mult mass g) in (* on ajoute la gravité *)
    let forces = 
          (* on ajoute les frottements du support *)       
        let f = Vector.mult (mass /. delta) { x= old_v.x *. -0.25 ; y = 0.0 } in
        Vector.add f forces 
    in
    let new_v = Vector.add old_v (Vector.mult (delta/. mass) forces) in
    Velocity.set e new_v;
    SumForces.set e Vector.zero;
    ) el
