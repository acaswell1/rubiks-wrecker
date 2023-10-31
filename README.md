Names: Brandon Stride and Alec Caswell
JHED: bstride1, acaswel1

SUMMARY:
This deployment uses a front end user interface deployed at (RETIRED: http://rubiks-wrecker.herokuapp.com/) 
to send the current state of a Rubik's cube to the solver. The solver then uses a system of algorithms to compute
a solution for the given Rubik's cube.
This algorithm does not take an optimal approach but rather mimics the approach of an experienced human solver.
This way, the user can use Rubik's Wrecker as an aid in learning to solve the Rubik's cube. This is contrary to
many online solvers that employ Kociemba's algorithm, which seemingly works magic and is not a realistic way for
a human to solve a Rubik's cube. On the brightside, our algorithm solves the cube in 0.07 seconds on average,
whereas other, more optimal solvers take a few seconds.

Note: you must use the http version to access the full functionality of the application; the https version does
not have 'solve' functionality. There is no user information collected, so the risk for users accessing the website is minimal.
If your site defaults to https, you may need to disable automatic https.

BUILD AND RUN:
This app can be built using a standard 'dune build'. Then, by running the command 'dune exec ./server/server.exe',
users can run this program locally on their machines. Note: the Dream library will be needed to run this program,
as well ppx_jane.

RUN TEST:
There are two test files/directories for this app. Run these with the commands 'dune test cube_tests' and
'dune test solver_tests'. They test the physical correctness of the cube and the solving algorithm respectively.
After running these two commands, you're free to run 'bisect-ppx-report html' and view the coverage report.
Please note that solver_tests takes about 45 seconds to run because we use Quickcheck to test many different
cube configurations.
