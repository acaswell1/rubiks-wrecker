Brandon Stride and Alec Caswell
bstride1, acaswel1

SUMMARY:
This deployment uses a front end user interface deployed at (http://rubiks-wrecker.herokuapp.com/) 
to send the current state of a rubiks cube to the solver. The solver then uses a system of algorithms to 
compute a solution for the given rubiks cube. Many, but not all of the solutions calculated by the solver 
are in the least number of moves possible, or the optimal solution."

BUILD AND RUN:
This app can be built using a standard dune build, then by running the command 'dune exec ./server/server.exe'
users can run this program locally on their machines. Note, the Dream library will be needed to run this program
as well ppx_jane. 