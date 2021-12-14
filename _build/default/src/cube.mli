type t (* = (color option) Cube_map.t *)

val create : unit -> t (* Creates blank cube with only the middle facelets colored *)
val create_solved : unit -> t
val from_list : (Facelet.t * Color.t option) list -> t option
val is_solved : t -> bool
val is_well_formed : t -> bool
val equal_cube : t -> t -> bool
val get : t -> Facelet.t -> Color.t option
val set : t -> Facelet.t -> Color.t option -> (t, string) result
val move : t -> Turn.t -> t
val move_seq : t -> Turn.t list -> t
val scramble : unit -> t