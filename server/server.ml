open Core;;
open Cube;;
open Solver;;


let color_converter (face : Facelet.t) (c : Cube.t): string = 
  match Cube.get c face with
  | Some x -> let col = Color.to_string x in 
    if String.equal col "blue" then "blue  " 
    else if String.equal col "red" then "red   " 
    else if String.equal col "yellow" then "yellow"
    else if String.equal col "orange" then "orange"
    else if String.equal col "green" then "green "
    else if String.equal col "white" then "white " else 
    "Error "
  | None -> "Error ";;

let face_list = Facelet.([U1; U2; U3; U4; U5; U6; U7; U8; U9;
L1; L2; L3; L4; L5; L6; L7; L8; L9;
F1; F2; F3; F4; F5; F6; F7; F8; F9;
R1; R2; R3; R4; R5; R6; R7; R8; R9;
B1; B2; B3; B4; B5; B6; B7; B8; B9;
D1; D2; D3; D4; D5; D6; D7; D8; D9])

let rec color_list (face_list: Facelet.t list): string = 
let c = create_solved () in 
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

let format_string (list_moves: Turn.t list) = 
  List.chunks_of ~length:6 list_moves 
  |> List.map ~f:(List.to_string ~f:Turn.to_string)
  |> List.to_string ~f:Fn.id
  |> String.filter ~f:(fun c -> not @@ Char.equal c '"')

let get_solution (solution_cube) = 
  match get_solution solution_cube with
  | Ok x -> x |> format_string
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
  Dream.run ~interface:"0.0.0.0" ~port:(int_of_string (Sys.getenv_exn "PORT"))
  @@ Dream.logger 
  @@ Dream.router [ 
  Dream.get "/" (fun _ -> color_list (face_list) |> Template.render |>
      Dream.html);

  Dream.get "/websocket"
  (fun _ -> Dream.websocket (fun websocket ->
    match%lwt Dream.receive websocket with
    | Some x -> let%lwt () = Dream.send websocket (solve x) in Dream.close_websocket websocket
    | None -> Dream.close_websocket websocket));
  ]
  @@ Dream.not_found