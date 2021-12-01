

module Cube (R: Randomness) : Cube_interface = struct

  module Turn = struct
    type t = R | R2 | R'
          | B | B2 | B'
          | L | L2 | L'
          | F | F2 | F'
          | U | U2 | U'
          | D | D2 | D'
          [@@deriving compare, sexp]
  end

  type turn = Turn.t

  include Turn

  module Turn_map : (Map.S with type Key.t = turn) = Map.Make(Turn)

  let all_turns = [R; R2; R';
                  B; B2; B';
                  L; L2; L';
                  F; F2; F';
                  U; U2; U';
                  D; D2; D']

  module Facelet = struct
    type t = R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9
            | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9
            | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9
            | F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | F9
            | U1 | U2 | U3 | U4 | U5 | U6 | U7 | U8 | U9
            | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9
            [@@deriving equal, compare, sexp]
  end

  type facelet = Facelet.t

  (* This will override Turn.t *)
  include Facelet

  type color = Bl | Or | Gr | Re | Wh | Ye [@@deriving equal]

  module Cube_map : (Map.S with type Key.t = facelet) = Map.Make(Facelet)

  (* This will override Facelet.t *)
  type t = (color option) Cube_map.t

  (* This is the solved configuration for the cube.
    If this is precisely the set of values, then the cube is solve.
    This also doubles as the keys in the map. *)
  let all_facelets = [R1; R2; R3; R4; R5; R6; R7; R8; R9;
                      B1; B2; B3; B4; B5; B6; B7; B8; B9;
                      L1; L2; L3; L4; L5; L6; L7; L8; L9;
                      F1; F2; F3; F4; F5; F6; F7; F8; F9;
                      U1; U2; U3; U4; U5; U6; U7; U8; U9;
                      D1; D2; D3; D4; D5; D6; D7; D8; D9]

  let colors = [Bl; Or; Gr; Re; Wh; Ye] (* Colors corresponding to each face of cube RBLFUD *)
  let center_facelets = [R5; B5; L5; F5; U5; D5] (* Center facelets for each face RBLFUD *)

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

  (* The middle colors can never change, so rotations/symmetry are ignored.
    Therefore, a cube is solved iff it is exactly equal to create_solved () *)
  let is_solved (cube: t) : bool =
    Cube_map.equal (equal_option equal_color) cube @@ create_solved ()

  (* For now, just ensure there are 9 of each color.
    Later, make sure that each expected piece exists e.g.
    there is exactly one white-blue-red corner.
    
    NOTE: I cannot check if the cube is solveable.
        A cube is only solvable if no pieces were removed and put back
        in a different location. This requires solving it. I may do this later. *)
  let is_well_formed (cube: t) : bool =
    let cube_limited_to_color c = 
      Cube_map.filter cube ~f:(equal_option equal_color c)
    in
    colors
    |> List.for_all ~f:(fun c -> Some c |> cube_limited_to_color |> Cube_map.length |> equal_int 9)

  let get (cube: t) ~(facelet: facelet) : color option =
    match Cube_map.find cube facelet with
    | Some c_op -> c_op (* find gets Some (Some c), so get Some c *)
    | None -> None

  let set (cube: t) ~(facelet:facelet) ~(color: color option) : (t, string) result =
    if List.exists center_facelets ~f:(Facelet.equal facelet) then
      Error "Tried to change center facelet. Center facelets are fixed "
    else OK (Cube_map.set cube ~key:facelet ~data:color)

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

  (* Each move is a repetition of a single clockwise move.
      e.g. R2 is R twice and R' is R three times.
      Fill in a map of the equivalences.*)
  let turn_equivalence_map : (turn * int) Turn_map.t = 
    let get_clockwise_index i = i - Int.rem i 3 in (* Round down to the nearest multiple of 3 to get the clockwise turn in all_turns*)
    all_turns
    |> List.mapi ~f:(fun i turn -> (turn, (List.nth_exn all_turns @@ get_clockwise_index i, i % 3 + 1) ) )
    |> Turn_map.of_alist_exn


  let move (cube: t) (turn: turn) : t =
    let (turn, multiple) = match Turn_map.find turn_equivalence_map turn with
      | Some x -> x
      | None -> failwith "Turn not found!"
    in
    let make_move t c =
      t
      |> Turn_map.find turn_results (* Find the resulting list of facelets from the turn *)
      |> Option.value_exn (* Illegal turns are caught above, so this is safe *)
      |> List.map ~f:(fun facelet -> get c ~facelet:facelet) (* Get the colors that will fill in *)
      |> List.zip_exn all_facelets (* Zip colors with the facelet that they will replace *)
      |> Cube_map.of_alist_exn (* Populate the cube with these new facelet,color values *)
    in
    Fn.apply_n_times ~n:multiple (make_move turn) cube (* apply the turn multiple times*)


  let scramble () : t =
    let n = List.length all_turns in
    20 (* Need at least 19 moves to scramble based on some source I found. Use 20. *)
    |> List.init ~f:(fun _ -> List.nth_exn all_turns (R.int n)) (* Create list of random turns *)
    |> List.fold ~init:(create_solved ()) ~f:move

end