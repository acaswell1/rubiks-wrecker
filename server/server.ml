open Core;;
open Cube;;
open Solver;;


let color_converter (face : Facelet.t) (c : Cube.t): string = 
  match Cube.get c face with
  | Some x -> let col = Color.to_string x in 
    if compare (String.compare col "blue") 0 = 0 then "blue  " 
    else if compare (String.compare col "red") 0 = 0 then "red   " 
    else if compare (String.compare col "yellow") 0 = 0 then "yellow"
    else if compare (String.compare col "orange") 0 = 0 then "orange"
    else if compare (String.compare col "green") 0 = 0 then "green "
    else if compare (String.compare col "white") 0 = 0 then "white " else 
    "Error "
  | None -> "Error ";;

let face_list =
[Facelet.U1; Facelet.U2; Facelet.U3; Facelet.U4; Facelet.U5; Facelet.U6; Facelet.U7; Facelet.U8; Facelet.U9;
Facelet.L1; Facelet.L2; Facelet.L3; Facelet.L4; Facelet.L5; Facelet.L6; Facelet.L7; Facelet.L8; Facelet.L9;
Facelet.F1; Facelet.F2; Facelet.F3; Facelet.F4; Facelet.F5; Facelet.F6; Facelet.F7; Facelet.F8; Facelet.F9;
Facelet.R1; Facelet.R2; Facelet.R3; Facelet.R4; Facelet.R5; Facelet.R6; Facelet.R7; Facelet.R8; Facelet.R9;
Facelet.B1; Facelet.B2; Facelet.B3; Facelet.B4; Facelet.B5; Facelet.B6; Facelet.B7; Facelet.B8; Facelet.B9;
Facelet.D1; Facelet.D2; Facelet.D3; Facelet.D4; Facelet.D5; Facelet.D6; Facelet.D7; Facelet.D8; Facelet.D9;]

let rec color_list (face_list: Facelet.t list): string = 
let c = scramble () in 
  match face_list with
    | x :: xs -> color_converter x c ^ color_list xs
    | [] -> ""

let rec set_facelets_to_color (list_facelets) (list_colors: color option list) =
  match list_facelets, list_colors with
  | x::xs, (Some y)::ys -> (x, (Some y)) :: set_facelets_to_color xs ys
  | [], _::_ -> []
  | x::xs, [] -> (x, None) :: set_facelets_to_color xs []
  | [], [] -> []
  | x::xs, None::ys -> (x, None) :: set_facelets_to_color xs ys
  
let solution_cube = set_facelets_to_color face_list 

let get_solution (solution_cube) = 
  match get_solution solution_cube with
  | Ok x -> List.to_string ~f:(fun y -> Turn.to_string y) x 
  | Error y -> y

let ensure_cube_correct (cube_from_list) =
  match cube_from_list with 
  | Some c -> get_solution c
  | None -> "Not a Well-Formed Cube"

let solve (color_string) : string = 
  let list_colors = String.split_on_chars ~on:[','] color_string 
  |> List.map ~f:(fun x -> Color.from_string x) in 
  set_facelets_to_color face_list list_colors 
  |> from_list 
  |> ensure_cube_correct
  

let () =
  Dream.run 
  @@ Dream.logger 
  @@ Dream.router [ 
  Dream.get "/" (fun _ -> color_list (face_list) |> Template.render |>
      Dream.html);

  Dream.get "/websocket"
  (fun _ -> Dream.websocket (fun websocket ->
    match%lwt Dream.receive websocket with
    | Some "Test" -> let%lwt () = Dream.send websocket "Pass" in Dream.close_websocket websocket
    | Some x -> let%lwt () = Dream.send websocket (solve x) in Dream.close_websocket websocket
    | _ -> Dream.close_websocket websocket));
  ]
  @@ Dream.not_found