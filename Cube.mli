
(* This is to scramble/randomize the cube *)
module type Randomness = sig
    (*
      Given a maximum integer value, return
      a pseudorandom integer from 0 (inclusive) to this value (exclusive).
    *)
    val int : int -> int
  end


module type Cube (R: Randomness) = sig

    module type Coord = sig
        type coord = {x: int; y: int} [@@deriving compare, sexp]
    end
    include Coord

    type color = R | B | Y | G | W | O 

    module Cube_map : (Map.S with type Key.t = coord) = Map.Make(Coord)

    type t (* = (color option) Cube_map.t *)

    val create : unit -> t (* Creates blank cube *)
    
    val create_solved : unit -> t

    val is_solved : t -> bool

    val is_well_formed : t -> bool

    val scramble : unit -> t

    val get : t-> ~coord:coord -> color option

    val set : t -> ~coord:coord -> ~color:(color option) -> t

    val move : t -> string -> t (* There are too many moves to create our own type, so string is the move name. Fails if bad move *)

end