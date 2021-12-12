type t (* = (color option) Cube_map.t *)

val create : unit -> t (* Creates blank cube with only the middle facelets colored *)
val create_solved : unit -> t
val from_list : (Facelet.t * Color.t option) list -> t option
val is_solved : t -> bool
val is_well_formed : t -> bool
val equal_cube : t -> t -> bool
val get : t -> Facelet.t -> Color.t option
<<<<<<< HEAD
val set : t -> Facelet.t -> color:(Color.t option) -> (t, string) result
=======
val set : t -> Facelet.t -> Color.t option -> (t, string) result
>>>>>>> f86dca735dce7b022a6705eab7357622c16c7b7c
val move : t -> Turn.t -> t
val move_seq : t -> Turn.t list -> t
val scramble : unit -> t