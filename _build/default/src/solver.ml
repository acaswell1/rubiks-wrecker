open Core
open Turn
open Facelet
open Color
open Cube
open Consts
open Turn_stack
open Turn_stack.Let_syntax

type turn = Turn.t
type facelet = Facelet.t
type color = Color.t

  
let monadic_move (tn: turn) (c: Cube.t) : Cube.t Turn_stack.t =
  let%bind () = push tn in
  return (move c tn)

let monadic_move_seq (tn_seq: turn list) (c: Cube.t) : Cube.t Turn_stack.t =
  List.fold ~init:(return c) ~f:(fun accum tn -> let%bind cube = accum in monadic_move tn cube) tn_seq


let is_color (cube : Cube.t) (color : color) (flet : facelet) : bool =
  equal_option Color.equal (Some color) @@ get cube flet

(* Given the colors of the cubies, iterate over all cubies and apply the function f to each cubie.
  Before moving on to the next cube, it does the finishing move. *)
let for_each_cubie ~(cubie_colors: 'a list)
                  ~(adjacent_cubies: 'b list)
                  ~(color_selector: 'a -> Cube.t -> 'b -> bool)
                  ~(get_first_facelet: 'b -> facelet)
                  ~(f: Cube.t -> facelet -> Cube.t Turn_stack.t)
                  ~(finish_move: turn)
                  ~(cube: Cube.t) =
  List.fold cubie_colors ~init:(return cube) ~f:(fun cube c_tup -> (* Fold through every color of cubie *)
    let%bind c = cube in (* Extract cube from monad *)
    adjacent_cubies
    |> List.filter ~f:(color_selector c_tup c) (* limit to cubie that is exactly the desired color *)
    |> List.hd_exn (* Gets only element--safe if the cube is well-formed *)
    |> get_first_facelet (* Get the facelet of the first color because the second color is implied *)
    |> f c (* Apply function on this facelet *)
    >>= monadic_move finish_move (* Apply rotation/finish move so that the remaining colors can follow the same pattern *)
  )

(* Iterate over all edges by narrowing down the definition of a cubie *)
let for_each_edge ~(edge_colors: (color * color) list)
                  ~(f: Cube.t -> facelet -> Cube.t Turn_stack.t)
                  ~(finish_move: turn)
                  ~(cube: Cube.t) =
  for_each_cubie ~cubie_colors:edge_colors
    ~adjacent_cubies:adjacent_edges
    ~color_selector:(fun (c1, c2) cube (f1, f2) -> is_color cube c1 f1 && is_color cube c2 f2) (* match the two colors of the edge *)
    ~get_first_facelet:Tuple2.get1
    ~f:f
    ~finish_move:finish_move
    ~cube:cube


(* Will solve the yellow cross on the bottom of the cube.
  Strategy:
  i) Take it color-by-color i.e. solve Re, Bl, Or, then Gr sides
  ii) Find the Ye/[other color] piece by checking each possible edge
  iii) Move the edge piece into the F8/D2 position (i.e. FD) 
  iv) Do D' so that solving the next color puts in the proper position respective to the previous color
  v) All four colors means that there are four D' moves, so the cross is orientied correctly in the end.

  See consts.ml for definition of get_turns_to_FD used here.
  *)
let solve_yellow_cross (cube: Cube.t) : Cube.t Turn_stack.t =
  for_each_edge ~edge_colors:[(Ye, Re); (Ye, Bl); (Ye, Or); (Ye, Gr)] (* Looking for yellow edge pieces *)
                ~f:(fun cube flet -> flet |> get_turns_to_FD |> Fn.flip monadic_move_seq cube) (* With each edge piece, will put in Front/Down position *)
                ~finish_move:D' (* Rotate bottom layer once between colors *)
                ~cube:cube

let for_each_corner ~(corner_colors: (color * color * color) list)
                ~(f: Cube.t -> facelet -> Cube.t Turn_stack.t)
                ~(finish_move: turn)
                ~(cube: Cube.t) =
  for_each_cubie ~cubie_colors:corner_colors
                  ~adjacent_cubies:adjacent_corners
                  ~color_selector:(fun (c1, c2, c3) cube (f1, f2, f3) -> is_color cube c1 f1 && is_color cube c2 f2 && is_color cube c3 f3)
                  ~get_first_facelet:Tuple3.get1
                  ~f:f
                  ~finish_move:finish_move
                  ~cube:cube

(* Solves the yellow corners without affecting the edges on the bottom (i.e. doesn't mess up yellow cross)
  Method:
  i) Locate desired corner 
  ii) Put in bottom right corner
  iii) Rotate bottom face "left" so that next color can fit in bottom right
  iv) Repeat

  See consts.ml for definition of get_turns_to_DFR used here.
*)
let solve_yellow_corners (cube : Cube.t) : Cube.t Turn_stack.t =
  for_each_corner ~corner_colors:[(Ye, Re, Bl); (Ye, Bl, Or); (Ye, Or, Gr); (Ye, Gr, Re)] (* Look at all yellow corners *)
                  ~f:(fun cube flet -> flet |> get_turns_to_DFR |> Fn.flip monadic_move_seq cube) (* Solve this corner by putting it in bottom right *)
                  ~finish_move:D' (* Rotate bottom face so that next corner can go in bottom right *)
                  ~cube:cube

(* Is true iff there is some edge in the top layer that has no white facelet. *)
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

  See consts.ml for definition of get_turns_top_to_FR used here.
*)
let rec solve_middle_edges_in_top (cube : Cube.t) : Cube.t Turn_stack.t =
  for_each_edge ~edge_colors:[(Re, Bl); (Bl, Or); (Or, Gr); (Gr, Re)] (* Looking for middle-layer edge pieces *)
                ~f:(fun cube flet -> flet |> get_turns_top_to_FR |> Fn.flip monadic_move_seq cube) (* Move the edge to the front right position iff it's in the top layer *)
                ~finish_move:Y (* Finish with a whole rotation because we need the front right edge piece to move *)
                ~cube:cube
  >>= fun c -> if has_non_white_edge_in_top c then solve_middle_edges_in_top c else return c (* Repeat until no more white in top layer *)

(* Rotates the cube until the front center facelet is the desired color.
  Note: this will loop infinitely if the color is Ye or Wh, but that will never happen in the scope of this project. *)
let rec reset_center (color: color option) (cube: Cube.t) : Cube.t Turn_stack.t =
  if equal_option Color.equal color @@ get cube F5 then return cube (* Center is aligned. Nothing to do *)
  else monadic_move Y cube >>= reset_center color (* Center not aligned. Rotate and check if that worked *)

(* Puts the edge in the middle layer into FR s.t. flet is facing forward.
  This isn't as clunky as the other turn sequences, so I leave it here. *)
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
  >>= reset_center center_color (* Rotate until center is lined up again because we moved out of position *)

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
  and there are some flipped pieces.
*)
let solve_middle_edges_in_side (cube : Cube.t) : Cube.t Turn_stack.t =
  for_each_edge ~edge_colors:[(Re, Bl); (Bl, Or); (Or, Gr); (Gr, Re)]
                ~f:put_middle_edge_in_FR (* Move the edge to the front right position *)
                ~finish_move:Y (* Finish with a whole rotation because we need the front right edge piece to move *)
                ~cube:cube

let has_all_white (cube: Cube.t) (flets: facelet list) : bool =
  List.for_all flets ~f:(fun flet -> is_color cube Wh flet)

(* For final layer, I will take a different approach. I will do the 2Look OLL
  (orient last layer to get all white facing up), which requires a lot of pattern
  matching but is much faster than solving it similarly to the yellow face on the bottom.

  See consts.ml for defintion of oll_perms used here.
*)
let rec solve_OLL (cube : Cube.t) : Cube.t Turn_stack.t =
  let turn_seq = List.find oll_perms ~f:(fun (ls, _) -> has_all_white cube ls) in
  match turn_seq with
  | Some (_, seq) when List.is_empty seq -> return cube (* Cube matched the solved configuration, so return *)
  | Some (_, seq) -> monadic_move_seq seq cube >>= solve_OLL (* Matched an unsolved configuration, so do sequence and repeat *)
  | None -> monadic_move U cube >>= solve_OLL (* Didn't match any configuration, so rotate top face and try again *)

(* Given a list of colors, find the index of the first Re.
  This is to be used when checking the color of the outside facelets of the top layer
  after the OLL step [so first two layers are solved, and top face is all white].
  Thus we may assume the cube is well-formed *)
let get_red_index (cs: color list) : int =
  cs
  |> List.findi ~f:(fun _ c -> Color.equal Re c)
  |> Option.value ~default:(0, Wh) (* default is arbitrary because it will never be needed in uses of this function *)
  |> Tuple2.get1

(* Given a well-formed cube, return true iff the top edges are oriented properly,
  disregarding the starting color.
  i.e. they go Re -> Bl -> Or -> Gr and wrap around *)
let are_top_edges_solved (cube: Cube.t) : bool =
  let cs = [F2; R2; B2; L2]
    |> List.map ~f:(get cube)
    |> List.filter_opt (* we now have the colors of the outside edges *)
  in let ri = get_red_index cs in
  List.init 4 ~f:(fun i -> List.nth_exn cs @@ (ri + i) % 4) (* use the index of red to reorder list to have red first *)
  |> List.equal Color.equal [Re; Bl; Or; Gr] (* compare with expected order of colors *)


(* Now the white face is solved, and I only need to permute the cubies in the top layer 
  so that the sides are solved.
  
  See the algorithms here: http://www.cubewhiz.com/2lookpll.php. I convert them to work with
  the turns used in this project.

  I'll take a different approach yet again. This time, I will brute-force it even more by trying
  each of the algorithms and seeing if they work. There are four algorithms to permute the edges
  and three algorithms to permute the corners. That's not so bad.
  *)
let rec solve_PLL_edges (cube: Cube.t) : Cube.t Turn_stack.t =
  let soln = pll_edge_algorithms
    |> List.map ~f:(fun ls -> monadic_move_seq ls cube)
    |> List.filter ~f:(fun m -> run @@ let%bind cube = m in return (are_top_edges_solved cube))
  in match soln with
  | [] -> monadic_move U cube >>= solve_PLL_edges (* None of these algorithms solved the edges. Rotate once and try again *)
  | m :: [] -> m (* Found a solution. *)
  | _ -> failwith "Unexpected orientation after OLL; unsolvable edges by PLL"


(* Given a well-formed cube, return true iff the top layer is solved, disregarding orientation.
  That is, the colors on the outside facelets of the top layer are as expected, but they
  may not be aligned correctly s.t. the cube is solved.
*)
let is_top_layer_solved (cube: Cube.t) : bool =
  let cs = [F1; F2; F3; R1; R2; R3; B1; B2; B3; L1; L2; L3]
    |> List.map ~f:(get cube)
    |> List.filter_opt (* we know have the colors of all outside facelets *)
  in let ri = get_red_index cs in
  List.init 12 ~f:(fun i -> List.nth_exn cs @@ (ri + i) % 12) (* use the index of red to reorder list to have red first *)
  |> List.equal Color.equal [Re; Re; Re; Bl; Bl; Bl; Or; Or; Or; Gr; Gr; Gr] (* compare with expected order of colors *)


(* The final step is to solve the corners once the top face is all white and the edges
  are oriented correctly. Take the same approach as solving PLL edges.
  *)
let rec solve_PLL_corners (cube: Cube.t) : Cube.t Turn_stack.t =
  let soln = pll_corner_algorithms
    |> List.map ~f:(fun ls -> monadic_move_seq ls cube)
    |> List.filter ~f:(fun m -> run @@ let%bind cube = m in return (is_top_layer_solved cube)) (* Limit to algorithms that solved the top layer *)
  in match soln with
  | [] -> monadic_move U cube >>= solve_PLL_corners (* None of these algorithms solved the edges. Rotate once and try again *)
  | m :: [] -> m (* Found a solution. *)
  | _ -> failwith "Unexpected orientation after OLL; unsolvable corners by PLL"

(* Given a completely solved cube except for the rotation of the top face,
  finish solving the cube. *)
let rec solve_top_orientation (cube: Cube.t) : Cube.t Turn_stack.t =
  if is_color cube Re F2 then return cube (* We're done! Hooray! *)
  else monadic_move U cube >>= solve_top_orientation (* Red doesn't line up, turn top face until it does. *)

(* May be best to convert to move equivalences, then block into all of same type in a row, then convert back. *)
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
  if List.length res = List.length ls then res (* If length was not changed, then it's fully simplified *)
  else simplify res (* Length was changed, so try again to reduce further *)

let solve (cube: Cube.t) : Cube.t Turn_stack.t =
  cube
  |> solve_yellow_cross
  >>= solve_yellow_corners
  >>= solve_middle_edges_in_top
  >>= solve_middle_edges_in_side
  >>= solve_OLL
  >>= solve_PLL_edges
  >>= solve_PLL_corners
  >>= solve_top_orientation

let monadic_main (cube : Cube.t) : (turn list) Turn_stack.t =
  let%bind _ = solve cube in (* assign to _ because we assume cube will be solved, so no need to return it *)
  let%bind s = get_rev_stack in
  return @@ simplify s (* At this point I really don't need the monad *)

let get_solution (cube: Cube.t) : (turn list, string) result =
  try
    Ok (run @@ monadic_main cube)
  with _ -> (* Ignore exception and assume it's from non-well-formedness because my tests never throw an error when cube is well-formed *)
    Error "Cube is not well-formed. It could not be solved. "
;;
