(lang dune 2.9)
  (generate_opam_files true)
  (authors "Brandon Stride" "Alec Caswell")
  (maintainers "bstride1@jh.edu" "acaswell@jhu.edu")
  (package
   (name rubiks-wrecker) 
   (synopsis "A solution to a given rubiks cube using Functional Programming")
   (description "This deployment uses a front end user interface deployed at (http://rubiks-wrecker.herokuapp.com/) 
   to send the current state of a rubiks cube to the solver. The solver then uses a system of algorithms to 
   compute a solution for the given rubiks cube. Many, but not all of the solutions calculated by the solver 
   are in the least number of moves possible, or the optimal solution.")
   (depends
    (ounit2 (> 2.0))
    (core (> 0.14.1))
    (dream (> 1.0.0~alpha2))
    (ppx_jane (> 0.14.0))
 ))
