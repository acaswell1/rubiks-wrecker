
(* This is really the only function needed to interact with the UI *)
val solve : Cube.t -> (Turn.t list, string) result


(* I reveal these only for testing purposes *)
val simplify : Turn.t list -> Turn.t list
val solve_yellow_cross  : Cube.t -> Cube.t Turn_stack.t
val solve_yellow_corners  : Cube.t -> Cube.t Turn_stack.t
val solve_middle_edges_in_top : Cube.t -> Cube.t Turn_stack.t
val solve_middle_edges_in_side : Cube.t -> Cube.t Turn_stack.t
