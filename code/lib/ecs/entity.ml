module E = struct
  type t = int

  let create =
    let c = ref 0 in
    fun () ->
      incr c;
      !c

  let pp ppf e = Format.fprintf ppf "<e:%d>" e

  let hash i = i

  let equal a b = a == b

  let compare a b = compare a b
end

module Table = Hashtbl.Make (E)
include E

let dummy = -1
