type t = R | R2 | R'
        | B | B2 | B'
        | L | L2 | L'
        | F | F2 | F'
        | U | U2 | U'
        | D | D2 | D'
        | Y | Y2 | Y' (* Turn cube through the axis between the U and D faces *)
        [@@deriving compare, sexp, quickcheck]

let all_turns = [R; R2; R';
                B; B2; B';
                L; L2; L';
                F; F2; F';
                U; U2; U';
<<<<<<< HEAD
                D; D2; D']
=======
                D; D2; D';
                Y; Y2; Y']
>>>>>>> f86dca735dce7b022a6705eab7357622c16c7b7c

let to_string (turn: t) = turn |> sexp_of_t |> Core.Sexp.to_string