open Core;;

(* Taken from Assignment5 and adapted to work for turns *)
module T = struct
  type turnstack = Turn.t list (* this is our "heap type" *)

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
  let push (t : Turn.t) : unit t = fun (s : turnstack) -> ((), t :: s)

  (* let push_many (t : turnstack) : unit t =
    fun (s : turnstack) ->
      ((), List.fold ~init:s ~f:(fun accum tn -> tn :: accum) t) *)

  (* pop should pop off and return the top element, i.e. the list head.
      Note for now if the charstack was empty you can just `failwith "empty pop"`.
      Also get() above had a unit argument but it is not needed, the
      state monad delays execution. *)
  (* let pop : turn t =
    fun (s : turnstack) ->
      match s with
      | t :: tl -> (t, tl)
      | _ -> failwith "empty pop" *)

  (* let is_empty : bool t = fun (s : turnstack) -> match s with [] -> (true, s) | _ -> (false, s) *)

  (* The turns are added to the stack in the reverse order that they are performed, so 
    use get_rev_stack to get the turns in the order they were performed. *)
  let get_rev_stack : turnstack t =
    fun (s : turnstack) -> (List.rev s, s)

end

include T
include Monad.Make (T)