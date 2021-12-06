type t = Bl | Or | Gr | Re | Wh | Ye [@@deriving equal, compare, sexp]

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
