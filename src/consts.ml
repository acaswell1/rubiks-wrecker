(* Here I have all of the big lists and maps with all of the constants.

    e.g. The list of moves to solve each permutation in the OLL stage.
    e.g. The map of move equivalences.
    e.g. The map of the resulting cube from each move.
    etc.
*)

open Core
open Turn
open Facelet
(* open Color *)

type turn = Turn.t
type facelet = Facelet.t
type color = Color.t

module Turn_map : (Map.S with type Key.t = turn) = Map.Make(Turn)

(* This is a map of the turn to the new configuration.
  The facelet list is the new facelet in the position that is designated
  by the all_facelet lists above.
  e.g. if the first elementh in turn_results[F] is U7, this means that
    under the move F, the facelet R1 takes on the color that U7 had
    because R1 is the first element in all_facelets. *)
let turn_results : (facelet list) Turn_map.t = 
  Turn_map.empty
  |> Turn_map.set ~key:R ~data:[R7; R4; R1; R8; R5; R2; R9; R6; R3;
                                U9; B2; B3; U6; B5; B6; U3; B8; B9;
                                L1; L2; L3; L4; L5; L6; L7; L8; L9;
                                F1; F2; D3; F4; F5; D6; F7; F8; D9;
                                U1; U2; F3; U4; U5; F6; U7; U8; F9;
                                D1; D2; B7; D4; D5; B4; D7; D8; B1]
  |> Turn_map.set ~key:B ~data:[R1; R2; D9; R4; R5; D8; R7; R8; D7;
                                B7; B4; B1; B8; B5; B2; B9; B6; B3;
                                U3; L2; L3; U2; L5; L6; U1; L8; L9;
                                F1; F2; F3; F4; F5; F6; F7; F8; F9;
                                R3; R6; R9; U4; U5; U6; U7; U8; U9;
                                D1; D2; D3; D4; D5; D6; L1; L4; L7]
  |> Turn_map.set ~key:L ~data:[R1; R2; R3; R4; R5; R6; R7; R8; R9;
                                B1; B2; D7; B4; B5; D4; B7; B8; D1;
                                L7; L4; L1; L8; L5; L2; L9; L6; L3;
                                U1; F2; F3; U4; F5; F6; U7; F8; F9;
                                B9; U2; U3; B6; U5; U6; B3; U8; U9;
                                F1; D2; D3; F4; D5; D6; F7; D8; D9]
  |> Turn_map.set ~key:F ~data:[U7; R2; R3; U8; R5; R6; U9; R8; R9;
                                B1; B2; B3; B4; B5; B6; B7; B8; B9;
                                L1; L2; D1; L4; L5; D2; L7; L8; D3;
                                F7; F4; F1; F8; F5; F2; F9; F6; F3;
                                U1; U2; U3; U4; U5; U6; L9; L6; L3;
                                R7; R4; R1; D4; D5; D6; D7; D8; D9]
  |> Turn_map.set ~key:U ~data:[B1; B2; B3; R4; R5; R6; R7; R8; R9;
                                L1; L2; L3; B4; B5; B6; B7; B8; B9;
                                F1; F2; F3; L4; L5; L6; L7; L8; L9;
                                R1; R2; R3; F4; F5; F6; F7; F8; F9;
                                U7; U4; U1; U8; U5; U2; U9; U6; U3;
                                D1; D2; D3; D4; D5; D6; D7; D8; D9]
  |> Turn_map.set ~key:D ~data:[R1; R2; R3; R4; R5; R6; F7; F8; F9;
                                B1; B2; B3; B4; B5; B6; R7; R8; R9;
                                L1; L2; L3; L4; L5; L6; B7; B8; B9;
                                F1; F2; F3; F4; F5; F6; L7; L8; L9;
                                U1; U2; U3; U4; U5; U6; U7; U8; U9;
                                D7; D4; D1; D8; D5; D2; D9; D6; D3]
  |> Turn_map.set ~key:Y ~data:[B1; B2; B3; B4; B5; B6; B7; B8; B9;
                                L1; L2; L3; L4; L5; L6; L7; L8; L9;
                                F1; F2; F3; F4; F5; F6; F7; F8; F9;
                                R1; R2; R3; R4; R5; R6; R7; R8; R9;
                                U7; U4; U1; U8; U5; U2; U9; U6; U3;
                                D3; D6; D9; D2; D5; D8; D1; D4; D7]



(* Each move is a repetition of a single clockwise move.
    e.g. R2 is R twice and R' is R three times.
    Fill in a map of the equivalences. *)
let turn_equivalence_map : (turn * int) Turn_map.t = 
  let get_clockwise_turn i = 
    i
    |> Int.round_down ~to_multiple_of:3 (* Round down to multiple of 3 to get the clockwise index in all_turns *)
    |> List.nth_exn all_turns (* nth_exn is safe because we only rounded down, and the index originally came from all_turns *)
  in
  all_turns
  |> List.mapi ~f:(fun i turn -> (turn, (get_clockwise_turn i, i % 3 + 1) ) )
  |> Turn_map.of_alist_exn

(* All ordered pairs of facelets that make an edge piece *)
let adjacent_edges =
  [(U8, F2); (U6, R2); (U2, B2); (U4, L2);
    (F8, D2); (R8, D6); (B8, D8); (L8, D4);
    (F6, R4); (R6, B4); (B6, L4); (L6, F4)] (* These are all unordered pairs of edge pieces *)
    |> fun ls -> ls @ (List.map ls ~f:Tuple2.swap) (* Also include the pairs in the other order *)


(* All ordered pairs of facelets that make a corner piece.
  Need to get all permutations in order to simply find the colored corners. *)
let adjacent_corners =
  let l1 = [(U9, R1, F3); (U3, B1, R3); (U1, L1, B3); (U7, F1, L3);
            (D9, R9, B7); (D3, F9, R7); (D1, L9, F7); (D7, B9, L7)] in
  let l2 = List.map l1 ~f:(fun (a, b, c) -> b, a, c) in
  let l3 = List.map l1 ~f:(fun (a, b, c) -> b, c, a) in
  let l4 = List.map l1 ~f:(fun (a, b, c) -> a, c, b) in
  let l5 = List.map l1 ~f:(fun (a, b, c) -> c, a, b) in
  let l6 = List.map l1 ~f:(fun (a, b, c) -> c, b, a) in
  l1 @ l2 @ l3 @ l4 @ l5 @ l6 (* These lists aren't that long, so this shouldn't be terribly slow *)

(* Gets the turn sequence that puts the given facelet into the 
  FD position with the given facelet facing DOWN. *)
let get_turns_to_FD (flet: facelet) : turn list = 
  match flet with
  | F8 -> [F'; D; R'; D']
  | F6 -> [D; R'; D']
  | F4 -> [D'; L; D]
  | F2 -> [F; D; R'; D']
  | R4 -> [F]
  | R2 -> [R'; F; R]
  | R8 -> [R; F]
  | R6 -> [R2; F; R2]
  | L6 -> [F']
  | L2 -> [L; F'; L']
  | L4 -> [L2; F'; L2]
  | L8 -> [L'; F']
  | B2 -> [U; R'; F; R]
  | B4 -> [D; R; D']
  | B6 -> [D'; L'; D]
  | B8 -> [B; D; R; D']
  | U8 -> [F2]
  | U6 -> [U; F2]
  | U2 -> [U2; F2]
  | U4 -> [U'; F2]
  | D2 -> []
  | D6 -> [R2; U; F2]
  | D8 -> [B2; U2; F2]
  | D4 -> [L2; U'; F2]
  | _ -> failwith "Not proper position for edge facelet"

(* Gets the turn sequence that puts the given facelet into the DFR corner
  with the given facelet facing DOWN. Does not mess up other bottom pieces.
  These are not confirmed to be the shortest solutions; they're just solutions I found.*)
let get_turns_to_DFR (flet : facelet) : turn list =
  (* Create a recursive function inside this with a shorter name *)
  let rec g (flet : facelet) : turn list =
    match flet with
    | D3 -> []
    | R7 -> [R; U; R'] @ g F1 (* Fine to use list append because such small lists *)
    | F9 -> [F'; U'; F] @ g R3
    | F3 -> [F'; U'; F]
    | R3 -> U :: g F3
    | B3 -> U2 :: g F3
    | L3 -> U' :: g F3
    | R1 -> [R; U; R']
    | B1 -> U :: g R1
    | L1 -> U2 :: g R1 
    | F1 -> U' :: g R1
    | U9 -> [R; U2; R'] @ g F1
    | U3 -> U :: g U9
    | U1 -> U2 :: g U9
    | U7 -> U' :: g U9
    | D9 -> [B; U; B'] @ g F3
    | B7 -> [B; U; B'] @ g R1
    | R9 -> [R'; U2; R] @ g L3
    | F7 -> [F; U; F'] @ g L1
    | L9 -> [L'; U'; L] @ g F3
    | D1 -> [L'; U'; L] @ g R1
    | B9 -> [B'; U'; B] @ g L3
    | L7 -> [L; U2; L'] @ g R1
    | D7 -> [B'; U'; B] @ g F1
    | _ -> failwith "Not proper position for corner facelet"
  in g flet

(* Gets the turn sequence that puts the edge with the given facelet in the FR position such that the given 
  facelet is on the front face. Does nothing if the facelet is not in the top position *)
let get_turns_top_to_FR (flet: facelet) =
  (* Create a recursive function inside this with a shorter name *)
  let rec g (flet : facelet) : turn list =
    match flet with
    | F2 -> [U; R; U'; R'; U'; F'; U; F]
    | L2 -> U' :: g F2
    | B2 -> U2 :: g F2
    | R2 -> U :: g F2
    | U6 -> [Y; U'; L'; U; L; U; F; U'; F'; Y'] (* Remember to "unrotate". This may get removed through final move simplification *)
    | U8 -> U' :: g U6
    | U4 -> U2 :: g U6
    | U2 -> U :: g U6
    | _ -> []
  in g flet

(* This is a list of white facelet permutations paired with the required OLL turn sequence.
  I get the algorithms from http://www.cubewhiz.com/2lookoll.php and adjust them to fit the
  moves I allow. *)
let oll_perms = 
  [
    (* Solve white cross *)
    ( [F2; U4; U5; U6; B2], [F; R; U; R'; U'; F'] );
    ( [U8; U5; U6; L2; B2], [B; U; L; U'; L'; B'] ); (* Modified from source to not include double face moves *)
    ( [U5; F2; R2; B2; L2], [F; R; U; R'; U'; F'; B; U; L; U'; L'; B'] );
    (* Done with white cross. The remaining states have the cross solved. *)
    ( [F1; F3; U1; U2; U3; U4; U5; U6; U8], [R2; D; R'; U2; R; D'; R'; U2; R'] );
    ( [B1; F3; U1; U2; U4; U5; U6; U7; U8], [R'; F'; L; F; R; F'; L'; F] ); (* Modified to not include double face moves *)
    ( [F1; R3; U1; U2; U4; U5; U6; U8; U9], [R'; F; R; B'; R'; F'; R; B] );
    ( [B3; R3; F3; U2; U4; U5; U6; U7; U8], [R; U; R'; U; R; U2; R'] );
    ( [L1; F1; R1; U2; U3; U4; U5; U6; U8], [R; U2; R'; U'; R; U'; R'] );
    ( [L1; L3; B1; F3; U2; U4; U5; U6; U8], [R; U2; R2; U'; R2; U'; R2; U2; R] );
    ( [B1; B3; F1; F3; U2; U4; U5; U6; U8], [R; U2; R'; U'; R; U; R'; U'; R; U'; R'] );
    ( [U1; U2; U3; U4; U5; U6; U7; U8; U9], [] ); (* White face is solved; all white facelets are upwards *)
  ]

(* This is the list of algorithms that solve the edges after the oll stage.
  I get the algorithms from http://www.cubewhiz.com/2lookpll.php and adjust them to fit the
  moves I allow.*)
let pll_edge_algorithms =
  [
    []; (* Also consider no solution necessary *)
    [R; U'; R; U; R; U; R; U'; R'; U'; R2];
    [R2; U; R; U; R'; U'; R'; U'; R'; U; R'];
    (* [R2; L2; D; R2; L2; U2; R2; L2; D; R2; L2]; *) (* Keeps solved state, so is "hidden" by no solution *)
    [R2; L2; D; R2; L2; U; R; L'; B2; R2; L2; F2; R; L'; U2]
  ]

(* This is the list of algorithms that solve the corners after the oll stage.
  I get the algorithms from http://www.cubewhiz.com/2lookpll.php and adjust them to fit the
  moves I allow.*)
let pll_corner_algorithms =
  [
    []; (* Also consider no solution necessary *)
    [R'; F; R'; B2; R; F'; R'; B2; R2];
    [R2; B2; R; F; R'; B2; R; F'; R];
    [R; B'; R'; F; R; B; R'; F'; R; B; R'; F; R; B'; R'; F'];
    [R'; F; R'; B2; R; F'; R'; B2; R2; U'; R'; F; R'; B2; R; F'; R'; B2; R2];
    [R2; B2; R; F; R'; B2; R; F'; R; U; R2; B2; R; F; R'; B2; R; F'; R]
  ]