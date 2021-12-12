open Core;;
open OUnit2;;
open Turn;;
open Facelet;;
open Color;;
open Cube;;

type color = Color.t

let c = create_solved ();;

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

let test_set _ =
  let c = set (create ()) R2 (Some Re) |> Result.ok_or_failwith |> fun cube -> get cube R2 in
  assert_equal (Some Re) c;
  assert_equal true @@ Result.is_error (set (create ()) F5 (Some Bl));
;;

let creation_tests = 
  "Creation tests" >: test_list [
    "Create" >:: test_create;
    "Create solved" >:: test_create_solved;
    "Well-formed" >:: test_is_well_formed;
    "Set" >:: test_set;
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

let eq ls turn = 
  assert_equal true @@ equal_cube (move c turn) (move_seq c ls)

let test_move_equivalences _ =
  eq [R; R; R] R';
  eq [R; R] R2;
  eq [L; L; L] L';
  eq [L; L] L2;
  eq [U; U; U] U';
  eq [U; U] U2;
  eq [F; F; F] F';
  eq [F; F] F2;
  eq [D; D; D] D';
  eq [D; D] D2;
  eq [B; B; B] B';
  eq [B; B] B2;
;;

(* Returns if the given colors equal the cube configuration after the moves *)
let move_seq_template (moves: Turn.t list) (colors: color list) : bool =
  let c1 = Cube.from_list (
    colors
    |> List.map ~f:Option.return
    |> List.zip_exn all_facelets
  ) in
  equal_cube (Option.value_exn c1) (move_seq c moves)
;;

(* I'll just create some "random" sequences and input the colors I see on my cube *)
let test_move_sequences _ =
  assert_equal true @@ move_seq_template [R] [Bl; Bl; Bl; Bl; Bl; Bl; Bl; Bl; Bl;
                                              Wh; Or; Or; Wh; Or; Or; Wh; Or; Or;
                                              Gr; Gr; Gr; Gr; Gr; Gr; Gr; Gr; Gr;
                                              Re; Re; Ye; Re; Re; Ye; Re; Re; Ye;
                                              Wh; Wh; Re; Wh; Wh; Re; Wh; Wh; Re;
                                              Ye; Ye; Or; Ye; Ye; Or; Ye; Ye; Or;];
  assert_equal true @@ move_seq_template [R; U; L'; F'; D2; B; R2; U] [Wh; Wh; Gr; Gr; Bl; Ye; Gr; Or; Or;
                                                                      Wh; Gr; Re; Re; Or; Gr; Ye; Wh; Re;
                                                                      Bl; Ye; Ye; Wh; Gr; Re; Bl; Bl; Bl;
                                                                      Gr; Gr; Re; Bl; Re; Ye; Wh; Or; Ye;
                                                                      Wh; Re; Or; Bl; Wh; Bl; Or; Or; Gr;
                                                                      Or; Ye; Re; Or; Ye; Wh; Ye; Re; Bl];
  assert_equal true @@ move_seq_template [U; F; L'; U2; B2; D2; U; R; U'; L'; U; R'] [Wh; Or; Or; Wh; Bl; Re; Ye; Gr; Gr;
                                                                                      Bl; Gr; Wh; Wh; Or; Wh; Ye; Re; Re;
                                                                                      Re; Gr; Gr; Or; Gr; Bl; Gr; Bl; Wh;
                                                                                      Ye; Ye; Gr; Ye; Re; Bl; Or; Re; Bl;
                                                                                      Bl; Ye; Ye; Wh; Wh; Ye; Re; Re; Or;
                                                                                      Bl; Gr; Re; Or; Ye; Or; Wh; Bl; Or];
;;

let move_tests =
  "Move tests" >: test_list [
    "Move invariants" >:: test_move_invariant;
    "Move equivalences" >:: test_move_equivalences;
    "Move sequences" >:: test_move_sequences;
  ]
;;


let series =
  "All tests" >::: [
    creation_tests;
    move_tests;
  ]
;;

let () =
  run_test_tt_main series