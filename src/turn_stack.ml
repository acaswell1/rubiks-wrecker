open Core;;

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

  (* Pushes the turn onto the turnstack and return () as the value *)
  let push (t : Turn.t) : unit t = fun (s : turnstack) -> ((), t :: s)

  (* The turns are added to the stack in the reverse order that they are performed, so 
    use get_rev_stack to get the turns in the order they were performed. *)
  let get_rev_stack : turnstack t =
    fun (s : turnstack) -> (List.rev s, s)

end

include T
include Monad.Make (T)