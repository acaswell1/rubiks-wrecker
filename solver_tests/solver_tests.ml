open Core;;
open OUnit2;;
(* open Turn;; *)
open Facelet;;
open Color;;
open Cube;;
open Solver;;

type color = Color.t

let c = create_solved ();;

let is_yellow_cross_solved cube =
  let expected_colors = [Ye; Ye; Ye; Ye; Re; Bl; Or; Gr] in
  [D2; D4; D6; D8; F8; R8; B8; L8]
  |> List.map ~f:(fun flet -> get cube flet)
  |> List.filter_opt
  |> List.zip_exn expected_colors
  |> List.for_all ~f:(fun (c1, c2) -> Color.equal c1 c2)
;;

let test_solve_yellow_cross _ =
  let turn_list_gen = (List.quickcheck_generator Turn.quickcheck_generator) in
  let my_test turn_list =
    (* Use turn list on solved cube, then solve cross and make sure the cross is indeed solved *)
    move_seq (create_solved ()) turn_list |> solve_yellow_cross |> Solver.Turn_stack.run |> is_yellow_cross_solved
  in
  Quickcheck.test turn_list_gen ~f:(fun ls -> assert (my_test ls)); (* This tests a #$%^-ton of random cube configurations to make sure yellow *)
;;

let solving_steps_tests = 
  "Steps tests" >: test_list [
    "Yellow cross" >:: test_solve_yellow_cross;
  ]
;;

let yellow_cross_invariant _ =
  assert_equal true (create_solved ()) |> solve_yellow_cross |> Solver.Turn_stack.run |> is_yellow_cross_solved);

let invariant_tests =
  "Invariant tests" >: test_list [
    "Yellow cross invariant" >:: yellow_cross_invariant;
  ]

let series =
  "All tests" >::: [
    solving_steps_tests;
    invariant_tests;
  ]
;;

let () =
  run_test_tt_main series