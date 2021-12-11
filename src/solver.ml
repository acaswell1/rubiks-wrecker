open Core
open Turn
open Facelet
open Color
open Cube
open Turn_stack
open Turn_stack.Let_syntax

type turn = Turn.t
type facelet = Facelet.t
type color = Color.t

  
let monadic_move (tn: turn) (c: Cube.t) : Cube.t Turn_stack.t =
  let%bind () = push tn in
  return (move c tn)
;;

let monadic_move_seq (tn_seq: turn list) (c: Cube.t) : Cube.t Turn_stack.t =
  List.fold ~init:(return c) ~f:(fun accum tn -> let%bind cube = accum in monadic_move tn cube) tn_seq
;;

let adjacent_edges =
  [(U8, F2); (U6, R2); (U2, B2); (U4, L2);
   (F8, D2); (R8, D6); (B8, D8); (L8, D4);
   (F6, R4); (R6, B4); (B6, L4); (L6, F4)] (* These are all unordered pairs of edge pieces *)
   |> fun ls -> ls @ (List.map ls ~f:Tuple2.swap) (* Also include the pairs in the other order *)

(* Need to get all permutations in order to simply find the colored corners *)
let adjacent_corners =
  let l1 = [(U9, R1, F3); (U3, B1, R3); (U1, L1, B3); (U7, F1, L3);
            (D9, R9, B7); (D3, F9, R7); (D1, L9, F7); (D7, B9, L7)] in
  let l2 = List.map l1 ~f:(fun (a, b, c) -> b, a, c) in
  let l3 = List.map l1 ~f:(fun (a, b, c) -> b, c, a) in
  let l4 = List.map l1 ~f:(fun (a, b, c) -> a, c, b) in
  let l5 = List.map l1 ~f:(fun (a, b, c) -> c, a, b) in
  let l6 = List.map l1 ~f:(fun (a, b, c) -> c, b, a) in
  l1 @ l2 @ l3 @ l4 @ l5 @ l6 (* These lists aren't that long, so this shouldn't be terribly slow *)

let is_color (cube : Cube.t) (color : color) (flet : facelet) : bool = 
  match get cube flet with
  | Some c -> Color.equal c color
  | _ -> false

(* Put the edge in the front/down edge position s.t. yellow is down and other down edges are unaffected.
  Notice how different all these solutions are; there is no elegant algorithm to solve this.

  There are a few repetitions (see F2-8) where recursion could work, but it's such a minority
  of cases that it seems best to just hard-code this in.

  These are the shortest ways I recognized how to solve each position.
  *)
let put_edge_in_FD (cube : Cube.t) (ye_flet: facelet) : Cube.t Turn_stack.t =
  let turn_seq = 
    match ye_flet with
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
    | _ -> failwith "Not proper position for yellow edge"
  in monadic_move_seq turn_seq cube


(* Will solve the yellow cross on the bottom of the cube.
  Strategy:
  i) Take it color-by-color i.e. solve Re, Bl, Or, then Gr sides
  ii) Find the Ye/[other color] piece by checking each possible position
  iii) Move the edge piece into the F8/D2 position (i.e. FD) 
  iv) Do D' so that solving the next color puts in the proper position respective to the previous color
  v) All four colors means that there are four D' moves, so the cross is orientied correctly.
  *)
let solve_yellow_cross (cube : Cube.t) : Cube.t Turn_stack.t =
  List.fold [Re; Bl; Or; Gr] ~init:(return cube) ~f:(fun cube color ->
      let%bind c = cube in
      adjacent_edges
      |> List.filter ~f:(fun (f1, f2) -> is_color c Ye f1 && is_color c color f2) (* limit to edge with Ye/[other color] *)
      |> List.hd_exn (* Gets only element--safe if the cube is well-formed *)
      |> Tuple2.get1 (* Get yellow facelet *)
      |> put_edge_in_FD c (* Solve this edge piece by putting in F8/D2 position *)
      >>= monadic_move D' (* finish off with D' move so that next color gets put in FD edge and is aligned properly with the edge we just solved *)
  )

(* Get the desired corner in the bottom right and make sure the given face is down.
  Don't mess up any other bottom pieces. *)
let put_corner_in_DFR (cube : Cube.t) (ye_flet: facelet) : Cube.t Turn_stack.t =
  (* Put the corner in the correct position by getting it out of bad positions into known ones.
    Great spot for recursion because lots of overlapping sequences. However, there is still
    and ugly amount of pattern-matching and algorithms *)
  let rec get_turn_seq (flet : facelet) : turn list =
    match flet with
    | D3 -> []
    | R7 -> [R; U; R'] @ get_turn_seq F1 (* Fine to use list append because such small lists *)
    | F9 -> [F'; U'; F] @ get_turn_seq R3
    | F3 -> [F'; U'; F]
    | R3 -> U :: get_turn_seq F3
    | B3 -> U2 :: get_turn_seq F3
    | L3 -> U' :: get_turn_seq F3
    | R1 -> [R; U; R']
    | B1 -> U :: get_turn_seq R1
    | L1 -> U2 :: get_turn_seq R1 
    | F1 -> U' :: get_turn_seq R1
    | U9 -> [R; U2; R'] @ get_turn_seq F1
    | U3 -> U :: get_turn_seq U9
    | U1 -> U2 :: get_turn_seq U9
    | U7 -> U' :: get_turn_seq U9
    | D9 -> [B; U; B'] @ get_turn_seq F3
    | B7 -> [B; U; B'] @ get_turn_seq R1
    | R9 -> [R'; U2; R] @ get_turn_seq L3
    | F7 -> [F; U; F'] @ get_turn_seq L1
    | L9 -> [L'; U'; L] @ get_turn_seq F3
    | D1 -> [L'; U'; L] @ get_turn_seq R1
    | B9 -> [B'; U'; B] @ get_turn_seq L3
    | L7 -> [L; U2; L'] @ get_turn_seq R1
    | D7 -> [B'; U'; B] @ get_turn_seq F1
    | _ -> failwith "Not proper position for yellow corner"
  in monadic_move_seq (get_turn_seq ye_flet) cube

(* Solves the yellow corners without affecting the edges on the bottom (i.e. doesn't mess up cross)
  Method:
  i) Locate desired corner 
  ii) Put in bottom right corner
  iii) Rotate bottom face "left" so that next color can fit it bottom right
  iv) Repeat
*)
let solve_yellow_corners (cube : Cube.t) : Cube.t Turn_stack.t =
  List.fold [(Re, Bl); (Bl, Or); (Or, Gr); (Gr, Re)] ~init:(return cube) ~f:(fun cube (c1, c2) ->
    let%bind c = cube in
    adjacent_corners
    |> List.filter ~f:(fun (f0, f1, f2) -> is_color c Ye f0 && is_color c c1 f1 && is_color c c2 f2) (* limit to corner with desired colors *)
    |> List.hd_exn (* Gets only element--safe if the cube is well-formed *)
    |> Tuple3.get1 (* Get yellow facelet *)
    |> put_corner_in_DFR c
    >>= monadic_move D' (* Rotate bottom face so that next color can simply go in bottom right. Happens four times, so gets full rotation *)
    )

(* Puts the edge with the given facelet in the FR position such that the given 
  facelet is on the front face. Does nothing if the facelet is not in the top position*)
let put_edge_in_FR_from_top (cube : Cube.t) (flet: facelet) : Cube.t Turn_stack.t =
  let rec get_turn_seq (f: facelet) =
    match f with
    | F2 -> [U; R; U'; R'; U'; F'; U; F]
    | L2 -> U' :: get_turn_seq F2
    | B2 -> U2 :: get_turn_seq F2
    | R2 -> U :: get_turn_seq F2
    | U6 -> [Y; U'; L'; U; L; U; F; U'; F'; Y'] (* Remember to "unrotate". This may get removed through final move simplification *)
    | U8 -> U' :: get_turn_seq U6
    | U4 -> U2 :: get_turn_seq U6
    | U2 -> U :: get_turn_seq U6
    | _ -> []
  in monadic_move_seq (get_turn_seq flet) cube

let has_non_white_edge_in_top (cube: Cube.t) : bool =
  [(U8, F2); (U6, R2); (U2, B2); (U4, L2)] (* These are exactly the top edges. *)
  |> List.filter ~f:(fun (f1, f2) -> not @@ is_color cube Wh f1 && not @@ is_color cube Wh f2) (* limit to edges with no white *)
  |> List.is_empty
  |> not

(* Solves the edges in the middle layer of the cube so that first two layers are solved if the
    yellow face was already solved.
  Method:
  i) Consider each edge in the top layer that has no white
  ii) Rotate cube to match with center color
  iii) Rotate top layer accordingly
  iv) Fit in FR
  v) Repeat
*)
let rec solve_middle_edges_in_top (cube : Cube.t) : Cube.t Turn_stack.t =
  List.fold [(Re, Bl); (Bl, Or); (Or, Gr); (Gr, Re)] ~init:(return cube) ~f:(fun cube (c1, c2) ->
    let%bind c = cube in
    adjacent_edges
    |> List.filter ~f:(fun (f1, f2) -> is_color c c1 f1 && is_color c c2 f2) (* limit to edge with desired two colors *)
    |> List.hd_exn (* Gets only element--safe if the cube is well-formed *)
    |> Tuple2.get1 (* Get the facelet of the first color because the second color is implied *)
    |> put_edge_in_FR_from_top c
    >>= monadic_move Y (* Rotate cube so that next color also needs to be put in FR *)
    )
    >>= fun c -> if has_non_white_edge_in_top c then solve_middle_edges_in_top c else return c (* Recurse until no white in top *)

let rec reset_center (color: color option) (cube: Cube.t) : Cube.t Turn_stack.t =
  if equal_option Color.equal color @@ get cube F5 then return cube (* Center is aligned. Nothing to do *)
  else monadic_move Y cube >>= reset_center color (* Center not aligned. Rotate and check if that worked *)

(* Puts the edge in the middle layer into FR s.t. flet is facing forward *)
let put_middle_edge_in_FR (cube : Cube.t) (flet: facelet) : Cube.t Turn_stack.t =
  let center_color = get cube F5 in
  let move_to_top_seq = [R; U; R'; U'; F'; U'; F] in (* moves to top from FR *)
  let turn_seq : turn list = (* This will either solve the piece or move into top layer *)
    match flet with
    | R4 -> [F2; U2; R'; F2; R; U2; F; U'; F] (* Correct position except piece is flipped *)
    | R6 | B4 -> Y :: move_to_top_seq @ [Y'] (* Move back right into top *)
    | B6 | L4 -> Y2 :: move_to_top_seq @ [Y2] (* Move back left into top *)
    | L6 | F4 -> Y' :: move_to_top_seq @ [Y] (* Move front left into top *)
    | F6 -> [] (* Is solved *)
    | _ -> failwith "Unexpected position for edge. Expected in middle layer."
  in
  monadic_move_seq turn_seq cube
  >>= reset_center (Some Re) (* Rotate to get the red facing forward so solving from top layer works properly *)
  >>= solve_middle_edges_in_top (* May need to solve a piece from the top layer, so do that now *)
  >>= reset_center center_color (* Rotate until center is lined up again we moved out of position *)

(* Assuming there are no non-white edges in the top layer, solve the middle edges.
  That is, all edges that need to be in the middle are already in the middle, and they
  just need to be moved around (or they are solved).
  Method:
  i) Locate each edge that is NOT solved
  ii) Move that edge into the top layer 
  iii) Solve the middle edges that are in the top.
  iv) Repeat.
  Note that I can't just move edges out of the middle and then solve the top because of the way edges get replaced.
  In fact, even though this seems like a long method, moving edges from top layer into middle layer first gets a lot
  of edges into the top layer and typically solves the middle layer altogether. I need this step in case we're unlucky
  and there are some flipped pieces. *)
let solve_middle_edges_in_side (cube : Cube.t) : Cube.t Turn_stack.t =
  List.fold [(Re, Bl); (Bl, Or); (Or, Gr); (Gr, Re)] ~init:(return cube) ~f:(fun cube (c1, c2) ->
    let%bind c = cube in
    adjacent_edges
    |> List.filter ~f:(fun (f1, f2) -> is_color c c1 f1 && is_color c c2 f2) (* limit to edge with desired two colors *)
    |> List.hd_exn (* Gets only element--safe if the cube is well-formed *)
    |> Tuple2.get1 (* Get the facelet of the first color because it is solved iff the facelet is F6 *)
    |> put_middle_edge_in_FR c
    >>= monadic_move Y (* Rotate cube so that next edge can be put in FR *)
    )

let parse (t1, t2 : turn * turn) : turn list =
  (* Yes, long and messy as usual in this program *)
  match t1, t2 with
  | R, R' | B, B' | L, L' | F, F' | U, U' | D, D' | Y, Y'
  | R', R | B', B | L', L | F', F | U', U | D', D | Y', Y
  | R2, R2 | B2, B2 | L2, L2 | F2, F2 | U2, U2 | D2, D2 | Y2, Y2 -> []
  | R, R2 | R2, R -> [R']
  | B, B2 | B2, B -> [B']
  | L, L2 | L2, L -> [L']
  | F, F2 | F2, F -> [F']
  | U, U2 | U2, U -> [U']
  | D, D2 | D2, D -> [D']
  | Y, Y2 | Y2, Y -> [Y']
  | R', R2 | R2, R' -> [R] (* Cannot convert to string and do this more algorithmically because of issues with ' character *)
  | B', B2 | B2, B' -> [B]
  | L', L2 | L2, L' -> [L]
  | F', F2 | F2, F' -> [F]
  | U', U2 | U2, U' -> [U]
  | D', D2 | D2, D' -> [D]
  | Y', Y2 | Y2, Y' -> [Y]
  | R, R | R', R' -> [R2]
  | B, B | B', B' -> [B2]
  | L, L | L', L' -> [L2]
  | F, F | F', F' -> [F2]
  | U, U | U', U' -> [U2]
  | D, D | D', D' -> [D2]
  | Y, Y | Y', Y' -> [Y2]
  | _ -> [t1; t2] (* catch the remaining cases by just putting back on stack*)

(* Simplify the turn list by replacing series of moves with identical moves.
  e.g. R R2 <=> R' *)
let rec simplify (ls : turn list) : turn list =
  let res = List.fold ls ~init:[] ~f:(fun stack next ->
    match stack with
    | top :: tail -> parse (next, top) @ tail
    | [] -> [next])
  |> List.rev (* Must reverse because used a stack, which reversed the order *)
  in
  if List.length res = List.length ls then res (* If length was not changed, so it's fully simplified *)
  else simplify res (* Length was changed, so try again to reduce further *)

let monadic_main (cube : Cube.t) : (turn list) Turn_stack.t =
  let%bind _ = (* assign to _ because we assume cube will be solved, so no need to return it *)
    cube
    |> solve_yellow_cross
    >>= solve_yellow_corners
    >>= solve_middle_edges_in_top
    >>= solve_middle_edges_in_side
  in
  let%bind s = get_rev_stack in
  return @@ simplify s (* At this point I really don't need the monad *)

let solve (cube: Cube.t) : (turn list, string) result =
  try
    Ok (run @@ monadic_main cube)
  with _ -> (* Ignore exception and assume it's from non-well-formedness because my tests never throw and error when cube is well-formed *)
    Error "Cube is not well-formed. It could not be solved. "
;;
