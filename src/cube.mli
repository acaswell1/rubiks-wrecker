
(* This is to scramble/randomize the cube *)
module type Randomness = sig
  (*
    Given a maximum integer value, return
    a pseudorandom integer from 0 (inclusive) to this value (exclusive).
  *)
  val int : int -> int
end

module type Turn = sig
  type t = R | R2 | R'
        | B | B2 | B'
        | L | L2 | L'
        | F | F2 | F'
        | U | U2 | U'
        | D | D2 | D' 
  val compare : t -> t -> int
  val sexp_of_t : t -> Sexp.t
  val t_of_sexp : Sexp.t -> t
end

module type Facelet = sig
  type t =  R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9
          | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9
          | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9
          | F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | F9
          | U1 | U2 | U3 | U4 | U5 | U6 | U7 | U8 | U9
          | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9
  val comapre : t -> t -> int
  val sexp_of_t : t -> Sexp.t
  val t_of_sexp : Sexp.t -> t
end

module type Cube_interface = sig

  module Turn_map : (Map.S with type Key.t = Turn.t) = Map.Make(Turn)

  type color = Bl | Or | Gr | Re | Wh | Ye [@@deriving equal]

  module Cube_map : (Map.S with type Key.t = Facelet.t) = Map.Make(Facelet)

  type t (* = (color option) Cube_map.t *)

  val create : unit -> t (* Creates blank cube with only the middle facelets colored *)
  val create_solved : unit -> t
  val is_solved : t -> bool
  val is_well_formed : t -> bool
  val get : t -> facelet:Facelet.t -> color option
  val set : t -> facelet:Facelet.t -> color:(color option) -> (t, string) result
  val move : t -> Turn.t -> t
  val scramble : unit -> t

end