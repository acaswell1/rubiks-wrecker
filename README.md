Names: Brandon Stride and Alec Caswell
JHED: bstride1, acaswel1

SUMMARY:
This deployment uses a front end user interface deployed at (http://rubiks-wrecker.herokuapp.com/) 
to send the current state of a rubiks cube to the solver. The solver then uses a system of algorithms to 
compute a solution for the given rubiks cube. This algorithm does not take an optimal approach but rather
mimics the approach of an experienced human solver. This way, the user can use Rubik's Wrecker as an aid
in learning to solve the Rubik's cube. This is contrary to many online solvers that employ Kociemba's algorithm,
which seemingly works magic and is not a realistic way for a human to solve a Rubik's cube.

BUILD AND RUN:
This app can be built using a standard dune build, then by running the command 'dune exec ./server/server.exe'
users can run this program locally on their machines. Note, the Dream library will be needed to run this program
as well ppx_jane. 