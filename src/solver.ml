open Core
open Turn
open Facelet
open Color
open Cube;;

type turn = Turn.t
type facelet = Facelet.t
type color = Color.t

(* Taken from Assignment5 and adapted to work for turns *)
module Turn_stack = struct
  module T = struct
    type turnstack = turn list (* this is our "heap type" *)

    type 'a t = turnstack -> 'a * turnstack

    let bind (x : 'a t) ~(f : 'a -> 'b t) : 'b t =
     fun (s : turnstack) ->
      let x', s' = x s in
      (f x') s'

    let return (x : 'a) : 'a t = fun (s : turnstack) -> (x, s)

    let map = `Define_using_bind

    (* Run puts us in c's monad-land with an empty stack
       Unlike with state monad above just throw away final stack here
    *)
    let run (c : 'a t) : 'a = match c [] with a, _ -> a

    (* pop should "push" the turn onto the turnstack and return () as the value *)
    let push (t : turn) : unit t = fun (s : turnstack) -> ((), t :: s)

    let push_many (t : turnstack) : unit t =
      fun (s : turnstack) ->
        ((), List.fold ~init:s ~f:(fun accum tn -> tn :: accum) t)

    (* pop should pop off and return the top element, i.e. the list head.
       Note for now if the charstack was empty you can just `failwith "empty pop"`.
       Also get() above had a unit argument but it is not needed, the
       state monad delays execution. *)
    let pop : turn t =
      fun (s : turnstack) ->
        match s with
        | t :: tl -> (t, tl)
        | _ -> failwith "empty pop"

    let is_empty : bool t = fun (s : turnstack) -> match s with [] -> (true, s) | _ -> (false, s)

    (* The turns are added to the stack in the reverse order that they are performed, so 
      use get_rev_stack to get the turns in the order they were performed. *)
    let get_rev_stack : turnstack t =
      fun (s : turnstack) -> (List.rev s, s)

  end

  include T
  include Monad.Make (T)
end

open Turn_stack
open Turn_stack.Let_syntax
  
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

let solve_yellow_corners (cube : Cube.t) : Cube.t Turn_stack.t =
  List.fold [(Re, Bl); (Bl, Or); (Or, Gr); (Gr, Re)] ~init:(return cube) ~f:(fun cube (c1, c2) ->
    let%bind c = cube in
    adjacent_corners
    |> List.filter ~f:(fun (f0, f1, f2) -> is_color c Ye f0 && is_color c c1 f1 && is_color c c2 f2) (* limit to corner with desired colors *)
    |> List.hd_exn (* Gets only element--safe if the cube is well-formed *)
    |> Tuple3.get1 (* Get yellow facelet *)
    |> put_corner_in_DFR c
    >>= monadic_move Y' (* Turn whole cube "left" i.e. clockwise around axis through top and bottom faces *)
    )
  
let parse (t1, t2 : turn * turn) : turn list =
  (* Yes, long and messy as usual in this program *)
  match t1, t2 with
  | R, R' | B, B' | L, L' | F, F' | U, U' | D, D'
  | R', R | B', B | L', L | F', F | U', U | D', D
  | R2, R2 | B2, B2 | L2, L2 | F2, F2 | U2, U2 | D2, D2 -> []
  | R, R2 | R2, R -> [R']
  | B, B2 | B2, B -> [B']
  | L, L2 | L2, L -> [L']
  | F, F2 | F2, F -> [F']
  | U, U2 | U2, U -> [U']
  | D, D2 | D2, D -> [D']
  | R', R2 | R2, R' -> [R] (* Cannot convert to string and do this more algorithmically because of issues with ' character *)
  | B', B2 | B2, B' -> [B]
  | L', L2 | L2, L' -> [L]
  | F', F2 | F2, F' -> [F]
  | U', U2 | U2, U' -> [U]
  | D', D2 | D2, D' -> [D]
  | R, R | R', R' -> [R2]
  | B, B | B', B' -> [B2]
  | L, L | L', L' -> [L2]
  | F, F | F', F' -> [F2]
  | U, U | U', U' -> [U2]
  | D, D | D', D' -> [D2]
  | _ -> [t1; t2] (* catch the remaining cases by just putting back on stack*)

(* Simplify the turn list by replacing pairs/triples of moves with identical moves. *)
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
  in
  let%bind s = get_rev_stack in
  return @@ simplify s


  (* let () =
    scramble ()
    |> monadic_main
    |> run
    |> List.to_string ~f:Turn.to_string
    |> print_endline *)
