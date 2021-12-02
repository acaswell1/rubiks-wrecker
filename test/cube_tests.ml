open Core;;
open OUnit2;;
open Turn;;
open Facelet;;
open Cube;;

let c = create_solved ();;

let test_nothing _ = assert_equal 0 0;;

let placeholder_tests =
  "Placeholder tests" >: test_list [
    "Nothing" >:: test_nothing;
  ]
;;

let test_create _ =
  let c0 = create () in
  assert_equal (Some Wh) (get c0 U5);
  assert_equal (None) (get c0 U1);
  assert_equal false @@ is_solved c0;
;;

let test_create_solved _ =
  assert_equal true @@ is_solved c;
  assert_equal true @@ is_well_formed c;
  assert_equal (Some Or) (get c B1);
;;

(* A better test would be created a cube piece-by-piece that I know is good
  and another cube that I know is not. *)
let test_is_well_formed _ =
  assert_equal true @@ is_well_formed (move c R);
  assert_equal false @@ is_well_formed (create ());
  assert_equal true @@ is_well_formed (scramble ());
;;

let creation_tests = 
  "Creation tests" >: test_list [
    "Create" >:: test_create;
    "Create solved" >:: test_create_solved;
    "Well-formed" >:: test_is_well_formed;
  ]
;;


let test_move_invariant _ =
  let seq = [R; U; R'; U'] in (* This sequence 6 times returns cube to original state *)
  let full_seq = List.init 6 ~f:(fun _ -> seq) |> List.join in
  assert_equal true @@ is_solved (move_seq c full_seq);
  assert_equal true @@ is_solved (move_seq c [R; R; R; R]);
  assert_equal true @@ is_solved (move_seq c [F2; F2]);
  assert_equal true @@ is_solved (move_seq c [U; U']);
;;

let move_seq_template (moves: Turn.t list) (colors: color list) : bool =
  let c1 = Cube.from_list (
    colors
    |> List.map ~f:Option.return
    |> List.zip_exn all_facelets
  ) in
  equal_cube (Option.value_exn c1) (move_seq c moves)

(* Not yet added to test list *)
let test_move_sequences _ =
  assert_equal true @@ move_seq_template [] [];
;;

let move_tests =
  "Move tests" >: test_list [
    "Move invariants" >:: test_move_invariant;
  ]
;;


let series =
  "All tests" >::: [
    placeholder_tests;
    creation_tests;
    move_tests;
  ]
;;

let () =
  run_test_tt_main series