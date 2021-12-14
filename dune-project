(lang dune 2.9)
  (generate_opam_files true)
  (authors "Brandon Stride" "Alec Caswell")
  (maintainers "bstride1@jh.edu" "acaswell@jhu.edu")
  (package
   (name rubiks-wrecker) 
   (synopsis "A solution to a given rubiks cube using Functional Programming")
   (description "This deployment uses a front end user interface deployed at (http://rubiks-wrecker.herokuapp.com/) 
    to send the current state of a rubiks cube to the solver. The solver then uses a system of algorithms to 
    compute a solution for the given rubiks cube. This algorithm does not take an optimal approach but rather
    mimics the approach of an experienced human solver. This way, the user can use Rubik's Wrecker as an aid
    in learning to solve the Rubik's cube. This is contrary to many online solvers that employ Kociemba's algorithm,
    which seemingly works magic and is not a realistic way for a human to solve a Rubik's cube.")
   (depends
    (ounit2 (> 2.0))
    (core (> 0.14.1))
    (dream (> 1.0.0~alpha2))
    (ppx_jane (> 0.14.0))
    (ppx_let (> 0.14.0))
    (bisect_ppx (> 2.7.0))
 ))
