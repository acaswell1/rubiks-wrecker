open Core;;
open Turn;;
open Facelet;;
open Color;;
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

let is_color (cube : Cube.t) (color : color) (flet : facelet) : bool = 
  match get cube flet with
  | Some c -> Color.equal c color
  | _ -> false

(* Put the edge in the front/down edge position s.t. yellow is down and other down edges are unaffected.
  Notice how different all these solutions are; there is no elegant algorithm to solve this.

  There are a few repetitions (see F2-8) where recursion could work, but it's such a minority
  of cases that it seems best to just hard-code this in.

  These may not be the ideals ways to solve each position, but these are the shortest ways I saw how to solve.
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
      |> List.filter ~f:(fun (f1, f2) -> is_color c Ye f1 && is_color c color f2) (* limit to edge with yellow/[other color] *)
      |> List.hd_exn (* Safe if the cube is well-formed *)
      |> Tuple2.get1 (* Get yellow facelet *)
      |> put_edge_in_FD c (* Solve this edge piece by putting in F8/D2 position *)
      >>= monadic_move D' (* finish off with D' move so that next color gets put in FD edge and is aligned properly with the edge we just solved *)
  )
  

let monadic_main (cube : Cube.t) : (turn list) Turn_stack.t =
  let%bind _ = (* assign to _ because we assume cube will be solved, so no need to return it *)
    cube
    |> solve_yellow_cross
    >>= return (* placeholder for next step *)
  in
  get_rev_stack

  (* let () =
    scramble ()
    |> monadic_main
    |> run
    |> List.to_string ~f:Turn.to_string
    |> print_endline *)
