param p;        		#number of user
param e;		  		#number of edges (split number)
param n;		  		#number of vertices
param s;				#number of different services


set U := {1..p};  		#set of demands from users, each user 1 demand
set N := {1..n};  		#set of vertices
set E := {1..e};  	    #set of edges
set S := {1..s};		#set of offered services


# Graph Parameters

## Edge Parameters
param A {E,N} >= 0;  #constant 1 if link e originates at node v;
param B {E,N} >= 0;  #constant 1 if link e terminates at node v;
param	C {E}	  >= 0;  #Capacity of link e;
param	L {E}   >= 0;  #Estimated delay of each link, can use stg prop to distance
#param P {E}   >= 0;  #Cost of link E

## Node Parameters
param	N_M {N} >= 0;  # Memory capacity of each node
param	N_C {N} >= 0;  # Computation Capacity of each node
param	N_K {N} >= 0;  # Maximum # users can be handled in a node

# Service Parameters
param S_M {S} >= 0;  # Memory requirement of each service
param S_C {S} >= 0;  # Computation requirement of each service
param S_T {S} >= 0;  # Maximum latency tolerance of a service
param S_H {S} >= 0;  # Volume of traffic for each service
param S_W {S} >= 0;  # The profit gain of a service for a MNO


# User Parameters
param U_S {U} integer; # The service requested by user U
param U_N {U,N} binary; # 1 if user can use access node 0 otherwise.


/*
# Variables Mixed Integer Programming
var x {N,U}   >= 0 binary;  # Placing a function on node N for user U
#var b {U}     >= 0 binary;  # Decision Var for serving a user or not
var y {N,U}   >= 0 binary;  # 1 if user u uses access node n
var u {U,E}	  >= 0 binary;  # 1 if the edge E is user do serve user U
var y {E} 	  >= 0; 		# The total volume of demands on link E
*/

# Variables Linear Programming
var x {N,U}   >= 0 binary;  # Placing a function on node N for user U
var y {N,U}   >= 0 binary;  # 1 if user u uses access node n
var u {U,E}	  >= 0 binary;  # 1 if the edge E is user do serve user U
#var y {E} 	  >= 0; 		# The total volume of demands on link E


# Objective Function
maximize z:  sum {f in U} sum {g in N} S_W[U_S[f]] *   x[g,f] ; # value of service selected by user u * is user served

# Deciding if user will be served
s.t. isUserServed {i in U}:
	sum {j in N} x[j,i] <= 1;

# can user u access through node n
s.t. canAccess {i in U, j in N}:
	y[j,i] <= U_N[i,j];

# Served users Access Network
s.t. whereAccess {ii in U}:
	sum {jj in N } U_N[ii,jj] * y[jj,ii] = sum {jj in N} x[jj,ii];

# Select routing links
s.t. routing {ii in U}:
	sum {ll in E} u[ii,ll] <= e * ( sum {jj in N} x[jj,ii] );

# obey the link capacities
s.t. linkCapacityConstraint {ll in E}:
	sum {ii in U} u[ii,ll] * S_H[ U_S[ii] ] <= C[ll]; 

# memory capacity of node
s.t. memNodeConstraint {jj in N}:
	sum {ii in U} x[jj,ii] * S_M[ U_S[ii] ] <= N_M[jj];

# computation capacity of node
s.t. capNodeConstraint {jj in N}:
	sum {ii in U} x[jj,ii] * S_C[ U_S[ii] ] <= N_C[jj];

# maximum served users for a node
s.t. connectionLimit {jj in N}:
	sum {ii in U} y[jj,ii] <= N_K[jj];

# service delay constraint
s.t. serviceDelay {ii in U}:
	sum {kk in E} u[ii,kk] * L[kk] <= S_T[ U_S[ii] ];

#each node follows flow conservation
s.t. NodeFlowConservationConstraint {jj in N , ii in U}: 
	sum {kk in E} (A[kk,jj] - B[kk,jj]) * u[ii,kk]  = y[jj,ii] - x[jj,ii];



