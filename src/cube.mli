
(* This is to scramble/randomize the cube *)
module type Randomness = sig
    (*
      Given a maximum integer value, return
      a pseudorandom integer from 0 (inclusive) to this value (exclusive).
    *)
    val int : int -> int
  end


module type Cube_interface =
  functor (R: Randomness) ->
    sig
      type color = Re | Bl | Ye | Gr | Wh | Or

      type turn = R | R' | R2
                | B | B' | B2
                | L | L' | L2
                | F | F' | F2
                | U | U' | U2
                | D | D' | D2

      module type Facelet = sig
        type t =  R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9
                | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9
                | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9
                | F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | F9
                | U1 | U2 | U3 | U4 | U5 | U6 | U7 | U8 | U9
                | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9
                [@@deriving compare, sexp]
      end

      module Cube_map : (Map.S with type Key.t = Facelet.t) = Map.Make(Facelet)

      type t (* = (color option) Cube_map.t *)

      val create : unit -> t (* Creates blank cube *)
      
      val create_solved : unit -> t

      val is_solved : t -> bool

      val is_well_formed : t -> bool

      val scramble : unit -> t

      val get : t-> ~facelet:Facelet.t -> color option

      val set : t -> ~facelet:Facelet.t -> ~color:(color option) -> t

      val move : t -> turn -> t
    end