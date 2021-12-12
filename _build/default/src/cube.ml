<<<<<<< HEAD
open Core;;
open Turn;;
open Facelet;;
open Color;;
=======
open Core
open Turn
open Facelet
open Color
open Consts
>>>>>>> f86dca735dce7b022a6705eab7357622c16c7b7c

type turn = Turn.t
type facelet = Facelet.t
type color = Color.t

module Cube_map : (Map.S with type Key.t = facelet) = Map.Make(Facelet)

type t = (color option) Cube_map.t

(* Create a blank cube with only the middle colors filled *)
let create () : t =
  let cube = all_facelets
  |> List.map ~f:(Fn.flip Tuple2.create None) (* Create tuples (facelet, None) *)
  |> Cube_map.of_alist_exn
  in
  center_facelets
  |> List.zip_exn colors (* Create tuples of (center facelet, Some color) *)
  |> List.fold ~init:cube ~f:(fun accum (c, flet) -> Cube_map.set accum ~key:flet ~data:(Some c)) (* Fill in middle colors *)


let create_solved () : t =
  List.init 54 ~f:(fun i -> List.nth_exn colors @@ i / 9 ) (* Colors corresponding to all_facelets *)
  |> List.map ~f:Option.return
  |> List.zip_exn all_facelets (* Create tuples (facelet, Some color) *)
  |> Cube_map.of_alist_exn

  (* For now, just ensure there are 9 of each color.
  Later, make sure that each expected piece exists e.g.
  there is exactly one white-blue-red corner.
  
  NOTE: I cannot check if the cube is solveable.
      A cube is only solvable if no pieces were removed and put back
      in a different location. This requires solving it. I may do this later. *)
let is_well_formed (cube: t) : bool =
  let cube_limited_to_color c = 
    Cube_map.filter cube ~f:(equal_option Color.equal c)
  in
  colors
  |> List.for_all ~f:(fun c -> Some c |> cube_limited_to_color |> Cube_map.length |> equal_int 9)

let from_list (ls: (Facelet.t * color option) list) : t option =
  let c_op = Option.try_with (fun () -> Cube_map.of_alist_exn ls) in (* ignore error messages and just keep as option *)
  match c_op with
  | Some c when is_well_formed c -> Some c
  | _ -> None

let equal_cube (c1: t) (c2: t) : bool =
  Cube_map.equal (equal_option Color.equal) c1 c2

(* The middle colors can never change, so rotations/symmetry are ignored.
  Therefore, a cube is solved iff it is exactly equal to create_solved () *)
let is_solved (cube: t) : bool =
  equal_cube cube @@ create_solved ()

let get (cube: t) (facelet: facelet) : color option =
  match Cube_map.find cube facelet with
  | Some c_op -> c_op (* find gets Some (Some c), so get Some c *)
  | None -> None

let set (cube: t) (facelet:facelet) (color: color option) : (t, string) result =
  if List.exists center_facelets ~f:(Facelet.equal facelet) then
    Error "Tried to change center facelet. Center facelets are fixed "
  else Ok (Cube_map.set cube ~key:facelet ~data:color)

let move (cube: t) (turn: turn) : t =
  let (turn, multiple) = match Turn_map.find turn_equivalence_map turn with
    | Some x -> x
    | None -> failwith "Turn not found!"
  in
  let make_move (t: turn) (c: t) =
    t
    |> Turn_map.find turn_results (* Find the resulting list of facelets from the turn *)
    |> Option.value_exn (* Illegal turns are caught above, so this is safe *)
    |> List.map ~f:(fun facelet -> get c facelet) (* Get the colors that will fill in *)
    |> List.zip_exn all_facelets (* Zip colors with the facelet that they will replace *)
    |> Cube_map.of_alist_exn (* Populate the cube with these new facelet,color values *)
  in
  Fn.apply_n_times ~n:multiple (make_move turn) cube (* apply the turn multiple times*)

let move_seq (cube: t) (ls: turn list) : t =
  List.fold ls ~init:cube ~f:move

let scramble () : t =
  let n = 18 in (* Only consider the first 18 turns because I don't want the rotation used in the scramble *)
  20 (* Need at least 19 moves to scramble based on some source I found. Use 20. *)
  |> List.init ~f:(fun _ -> List.nth_exn all_turns (Random.int n)) (* Create list of random turns *)
  |> List.fold ~init:(create_solved ()) ~f:move