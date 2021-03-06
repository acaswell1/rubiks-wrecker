(* This type has some conflicts with the turns because <face>2 is a turn.
    Context will make sure this is not a problem, and I specify types as much as possible. *)
type t = R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9
          | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9
          | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9
          | F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | F9
          | U1 | U2 | U3 | U4 | U5 | U6 | U7 | U8 | U9
          | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9
          [@@deriving equal, compare, sexp]

(* This is the solved configuration for the cube. *)
let all_facelets = [R1; R2; R3; R4; R5; R6; R7; R8; R9;
                    B1; B2; B3; B4; B5; B6; B7; B8; B9;
                    L1; L2; L3; L4; L5; L6; L7; L8; L9;
                    F1; F2; F3; F4; F5; F6; F7; F8; F9;
                    U1; U2; U3; U4; U5; U6; U7; U8; U9;
                    D1; D2; D3; D4; D5; D6; D7; D8; D9]

let center_facelets = [R5; B5; L5; F5; U5; D5] (* Center facelets for each face RBLFUD *)

let to_string (facelet: t) = facelet |> sexp_of_t |> Core.Sexp.to_string