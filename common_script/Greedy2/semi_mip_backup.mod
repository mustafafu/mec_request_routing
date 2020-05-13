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


