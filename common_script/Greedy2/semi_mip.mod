param N > 0 integer;	# number of nodes
param E > 0 integer;	# number of edges
param U > 0 integer;	# number of users
param S > 0 integer;	# number of services


set Nodes   := 1..N;	# set of nodes
set Services :=1..S;	# set of services
set Links   := 1..E;
set Users := 1..U;

# Capital letters are coming from data file, constants


## Link Parameters
param A {Links,Nodes} >= 0;  #constant 1 if link e originates at node v;
param B {Links,Nodes} >= 0;  #constant 1 if link e terminates at node v;
param C {Links}	  >= 0;  #Capacity of link e;
param XI {Links}  >= 0;  #Cost of link e;
param  L {Links}   >= 0;  #Estimated delay of each link, can use stg prop to distance

## Node Parameters
param	N_M {Nodes} >= 0;  # Memory capacity of each node
param	N_C {Nodes} >= 0;  # Computation Capacity of each node
param	N_K {Nodes} >= 0;  # Maximum # users can be handled in a node


## Service Parameters
param S_M {Services} >= 0;  # Memory requirement of each service
param S_C {Services} >= 0;  # Computation requirement of each service
param S_T {Services} >= 0;  # Maximum latency tolerance of a service
param S_H {Services} >= 0;  # Volume of traffic for each service
param S_W {Services} >= 0;  # The profit gain of a service for a MNO

## User Parameters
param U_S {Users} >= 0 integer;
param U_N {Users,Nodes} >= 0 binary; # 1 if user can use access node 0 otherwise.


# phrases are the variables we will use for optimization

## Variables
var server_indicator {Nodes,Users} >= 0 ;  # Placing a function on node N for user U
var access_indicator {Nodes,Users} >= 0 ; #1 if user u can access to network through node n.
var link_indicator {Users,Links} >= 0 binary; # 1 if the link e is used while serving the user u, 0 otherswise
var link_load {Links} >= 0;		  # load of link e.
var indicator {Nodes,Users} >= 0;


#####################################################################################################
## Optimization

## Objective Function
					# serving a user profit													 #cost of routing that user
maximize revenue: sum{u in Users} S_W[U_S[u]] * ( sum{n in Nodes} server_indicator[n,u] ) - sum{u in Users}(sum{e in Links} link_indicator[u,e] * XI[e] * link_load[e] );
	 

## a user can be served at most one location or neglected
s.t. served_constraint {u in Users}: 
	sum{n in Nodes} server_indicator[n,u] <= 1;


# Only the served users Access Network
s.t. access_constraint {u in Users , n in Nodes}:
	access_indicator [n,u] <= U_N[u,n];

# Selecting where to access the network
s.t. where_access {u in Users}:
	sum{n in Nodes} U_N[u,n] * access_indicator[n,u] = sum{n in Nodes} server_indicator[n,u];

# limiting the length of the service path when a user is served, else zeros
s.t. allocated_constraint {u in Users}:
	sum{e in Links} link_indicator[u,e] <= E * (sum{n in Nodes} server_indicator[n,u]);

# computing the load of each link
s.t. link_load_constraint {e in Links}:
	sum{u in Users} link_indicator[u,e] * S_H[U_S[u]] = link_load[e];

# Link hard capacity
s.t. link_bound_constraint {e in Links}:
	sum{u in Users} link_indicator[u,e] * S_H[U_S[u]] <= C[e];

# node memory constraint
s.t. node_memory_constraint {n in Nodes}:
	sum {u in Users} server_indicator[n,u] * S_M[U_S[u]] <= N_M[n];

# node computation constraint
s.t. node_computation_constraint {n in Nodes}:
	sum {u in Users} server_indicator[n,u] * S_C[U_S[u]] <= N_C[n];

# node number of user connectivity constraint
s.t. node_serving_constraint {n in Nodes}:
	sum {u in Users} access_indicator[n,u]  <= N_K[n];

# delay tolerance of each service constraint
s.t. service_delay_constraint {u in Users}:
	sum{e in Links} link_indicator[u,e] * L[e] <= S_T[U_S[u]];

# the routing
s.t. NodeFlowConservationConstraint {n in Nodes, u in Users}: 
	sum {e in Links} (A[e,n] - B[e,n]) * link_indicator[u,e]  = access_indicator[n,u] - server_indicator[n,u];
	
#s.t. indicator_c {u in Users, n in Nodes}:
#	indicator[n,u] = access_indicator[n,u];


s.t. C_fixone17: access_indicator[7,1] = 1;
s.t. C_fixone77: access_indicator[7,7] = 1;
s.t. C_fixone98: access_indicator[8,9] = 1;
s.t. C_fixone207: access_indicator[7,20] = 1;
s.t. C_fixone261: access_indicator[1,26] = 1;
s.t. C_fixone281: access_indicator[1,28] = 1;
s.t. C_fixone315: access_indicator[5,31] = 1;
s.t. C_fixone321: access_indicator[1,32] = 1;
s.t. C_fixone363: access_indicator[3,36] = 1;
s.t. C_fixone427: access_indicator[7,42] = 1;
s.t. C_fixone432: access_indicator[2,43] = 1;
s.t. C_fixone583: access_indicator[3,58] = 1;
s.t. C_fixone677: access_indicator[7,67] = 1;
s.t. C_fixone704: access_indicator[4,70] = 1;
s.t. C_fixone745: access_indicator[5,74] = 1;
s.t. C_fixone771: access_indicator[1,77] = 1;
s.t. C_fixone803: access_indicator[3,80] = 1;
s.t. C_fixone852: access_indicator[2,85] = 1;
s.t. C_fixone908: access_indicator[8,90] = 1;
s.t. C_fixone955: access_indicator[5,95] = 1;
s.t. C0: access_indicator[9,2] = 1;
s.t. C1: access_indicator[7,30] = 1;
s.t. C2: access_indicator[2,83] = 1;
s.t. C3: access_indicator[8,44] = 1;
s.t. C4: access_indicator[1,66] = 1;
s.t. access_constraint_lowerbound5 : sum {n in Nodes} access_indicator[n,45] = 0;
s.t. access_constraint_lowerbound6 : sum {n in Nodes} access_indicator[n,23] = 0;
s.t. C_fixzero39 : sum {n in Nodes} access_indicator[n,3] = 0;
s.t. C_fixzero49 : sum {n in Nodes} access_indicator[n,4] = 0;
s.t. C_fixzero59 : sum {n in Nodes} access_indicator[n,5] = 0;
s.t. C_fixzero69 : sum {n in Nodes} access_indicator[n,6] = 0;
s.t. C_fixzero89 : sum {n in Nodes} access_indicator[n,8] = 0;
s.t. C_fixzero109 : sum {n in Nodes} access_indicator[n,10] = 0;
s.t. C_fixzero119 : sum {n in Nodes} access_indicator[n,11] = 0;
s.t. C_fixzero129 : sum {n in Nodes} access_indicator[n,12] = 0;
s.t. C_fixzero139 : sum {n in Nodes} access_indicator[n,13] = 0;
s.t. C_fixzero149 : sum {n in Nodes} access_indicator[n,14] = 0;
s.t. C_fixzero159 : sum {n in Nodes} access_indicator[n,15] = 0;
s.t. C_fixzero169 : sum {n in Nodes} access_indicator[n,16] = 0;
s.t. C_fixzero179 : sum {n in Nodes} access_indicator[n,17] = 0;
s.t. C_fixzero189 : sum {n in Nodes} access_indicator[n,18] = 0;
s.t. C_fixzero199 : sum {n in Nodes} access_indicator[n,19] = 0;
s.t. C_fixzero219 : sum {n in Nodes} access_indicator[n,21] = 0;
s.t. C_fixzero229 : sum {n in Nodes} access_indicator[n,22] = 0;
s.t. C_fixzero239 : sum {n in Nodes} access_indicator[n,23] = 0;
s.t. C_fixzero249 : sum {n in Nodes} access_indicator[n,24] = 0;
s.t. C_fixzero259 : sum {n in Nodes} access_indicator[n,25] = 0;
s.t. C_fixzero279 : sum {n in Nodes} access_indicator[n,27] = 0;
s.t. C_fixzero299 : sum {n in Nodes} access_indicator[n,29] = 0;
s.t. C_fixzero339 : sum {n in Nodes} access_indicator[n,33] = 0;
s.t. C_fixzero349 : sum {n in Nodes} access_indicator[n,34] = 0;
s.t. C_fixzero359 : sum {n in Nodes} access_indicator[n,35] = 0;
s.t. C_fixzero379 : sum {n in Nodes} access_indicator[n,37] = 0;
s.t. C_fixzero389 : sum {n in Nodes} access_indicator[n,38] = 0;
s.t. C_fixzero399 : sum {n in Nodes} access_indicator[n,39] = 0;
s.t. C_fixzero409 : sum {n in Nodes} access_indicator[n,40] = 0;
s.t. C_fixzero419 : sum {n in Nodes} access_indicator[n,41] = 0;
s.t. C_fixzero459 : sum {n in Nodes} access_indicator[n,45] = 0;
s.t. C_fixzero469 : sum {n in Nodes} access_indicator[n,46] = 0;
s.t. C_fixzero479 : sum {n in Nodes} access_indicator[n,47] = 0;
s.t. C_fixzero489 : sum {n in Nodes} access_indicator[n,48] = 0;
s.t. C_fixzero499 : sum {n in Nodes} access_indicator[n,49] = 0;
s.t. C_fixzero509 : sum {n in Nodes} access_indicator[n,50] = 0;
s.t. C_fixzero519 : sum {n in Nodes} access_indicator[n,51] = 0;
s.t. C_fixzero529 : sum {n in Nodes} access_indicator[n,52] = 0;
s.t. C_fixzero539 : sum {n in Nodes} access_indicator[n,53] = 0;
s.t. C_fixzero549 : sum {n in Nodes} access_indicator[n,54] = 0;
s.t. C_fixzero559 : sum {n in Nodes} access_indicator[n,55] = 0;
s.t. C_fixzero569 : sum {n in Nodes} access_indicator[n,56] = 0;
s.t. C_fixzero579 : sum {n in Nodes} access_indicator[n,57] = 0;
s.t. C_fixzero599 : sum {n in Nodes} access_indicator[n,59] = 0;
s.t. C_fixzero609 : sum {n in Nodes} access_indicator[n,60] = 0;
s.t. C_fixzero619 : sum {n in Nodes} access_indicator[n,61] = 0;
s.t. C_fixzero629 : sum {n in Nodes} access_indicator[n,62] = 0;
s.t. C_fixzero639 : sum {n in Nodes} access_indicator[n,63] = 0;
s.t. C_fixzero649 : sum {n in Nodes} access_indicator[n,64] = 0;
s.t. C_fixzero659 : sum {n in Nodes} access_indicator[n,65] = 0;
s.t. C_fixzero689 : sum {n in Nodes} access_indicator[n,68] = 0;
s.t. C_fixzero699 : sum {n in Nodes} access_indicator[n,69] = 0;
s.t. C_fixzero719 : sum {n in Nodes} access_indicator[n,71] = 0;
s.t. C_fixzero729 : sum {n in Nodes} access_indicator[n,72] = 0;
s.t. C_fixzero739 : sum {n in Nodes} access_indicator[n,73] = 0;
s.t. C_fixzero759 : sum {n in Nodes} access_indicator[n,75] = 0;
s.t. C_fixzero769 : sum {n in Nodes} access_indicator[n,76] = 0;
s.t. C_fixzero789 : sum {n in Nodes} access_indicator[n,78] = 0;
s.t. C_fixzero799 : sum {n in Nodes} access_indicator[n,79] = 0;
s.t. C_fixzero819 : sum {n in Nodes} access_indicator[n,81] = 0;
s.t. C_fixzero829 : sum {n in Nodes} access_indicator[n,82] = 0;
s.t. C_fixzero849 : sum {n in Nodes} access_indicator[n,84] = 0;
s.t. C_fixzero869 : sum {n in Nodes} access_indicator[n,86] = 0;
s.t. C_fixzero879 : sum {n in Nodes} access_indicator[n,87] = 0;
s.t. C_fixzero889 : sum {n in Nodes} access_indicator[n,88] = 0;
s.t. C_fixzero899 : sum {n in Nodes} access_indicator[n,89] = 0;
s.t. C_fixzero919 : sum {n in Nodes} access_indicator[n,91] = 0;
s.t. C_fixzero929 : sum {n in Nodes} access_indicator[n,92] = 0;
s.t. C_fixzero939 : sum {n in Nodes} access_indicator[n,93] = 0;
s.t. C_fixzero949 : sum {n in Nodes} access_indicator[n,94] = 0;
s.t. C_fixzero969 : sum {n in Nodes} access_indicator[n,96] = 0;
s.t. C_fixzero979 : sum {n in Nodes} access_indicator[n,97] = 0;
s.t. C_fixzero989 : sum {n in Nodes} access_indicator[n,98] = 0;
s.t. C_fixzero999 : sum {n in Nodes} access_indicator[n,99] = 0;
s.t. C_fixzero1009 : sum {n in Nodes} access_indicator[n,100] = 0;
