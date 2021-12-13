type t = R | R2 | R'
        | B | B2 | B'
        | L | L2 | L'
        | F | F2 | F'
        | U | U2 | U'
        | D | D2 | D'
        | Y | Y2 | Y' (* Turn cube through the axis between the U and D faces *)
        [@@deriving equal, compare, sexp, quickcheck]

let all_turns = [R; R2; R';
                B; B2; B';
                L; L2; L';
                F; F2; F';
                U; U2; U';
                D; D2; D';
                Y; Y2; Y']

let to_string (turn: t) = turn |> sexp_of_t |> Core.Sexp.to_string

(* Map a turn to an int by its index in all_turns *)
let to_int (turn: t) : int =
        all_turns
        |> Core.List.findi ~f:(fun _ t -> equal turn t)
        |> Option.value ~default:(0, R) (* default is arbitrary because all_turns really does contain all turns. *)
        |> Core.Tuple2.get1 (* Get the index out of the pair *)


(* Map an int to a turn by index in all_turns. fail if out of bounds *)
let of_int_exn = Core.List.nth_exn all_turns