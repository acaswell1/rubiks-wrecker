type t = Bl | Or | Gr | Re | Wh | Ye [@@deriving equal, compare, sexp]

<<<<<<< HEAD
=======
let colors = [Bl; Or; Gr; Re; Wh; Ye] (* Colors corresponding to each face of cube RBLFUD *)

>>>>>>> f86dca735dce7b022a6705eab7357622c16c7b7c
let to_string (color: t) : string =
  match color with
  | Bl -> "blue"
  | Or -> "orange"
  | Gr -> "green"
  | Re -> "red"
  | Wh -> "white"
  | Ye -> "yellow"

let from_string (s: string) : t option =
  match String.lowercase_ascii s with
  | "blue" -> Some Bl
  | "orange" -> Some Or
  | "green" -> Some Gr
  | "red" -> Some Re
  | "white" -> Some Wh
  | "yellow" -> Some Ye
  | _ -> None
