open Core;;
(* open Turn;;
open Facelet;;
open Color;; *)
open Cube;;

(* let c = create_solved() ;; *)


let color_converter (face : Facelet.t) (c : Cube.t): string = match Cube.get c face with
| Some x -> let col = Color.to_string x in 
  if compare (String.compare col "blue") 0 = 0 then "blue  " 
  else if compare (String.compare col "red") 0 = 0 then "red   " 
  else if compare (String.compare col "yellow") 0 = 0 then "yellow"
  else if compare (String.compare col "orange") 0 = 0 then "orange"
  else if compare (String.compare col "green") 0 = 0 then "green "
  else if compare (String.compare col "white") 0 = 0 then "white " else 
  "Error "
| None -> "Error ";;

let face_list = Facelet.all_facelets

let rec color_list (face_list: Facelet.t list): string= 
let c = scramble () in 
  match face_list with
    | x :: xs -> color_converter x c ^ color_list xs
    | [] -> ""

let () =
  Dream.run 
  @@ Dream.logger 
  @@ Dream.router [
    
  Dream.get "/" (fun _ -> color_list (face_list) |> Template.render |>
      Dream.html);

  Dream.get "/random" (fun _ -> color_list (face_list) |> Template.render |>
  Dream.html)

  ]
  @@ Dream.not_found