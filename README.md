# Latency Focused Function Placement and Request Routing in Multi Access Mobile Edge Computing Networks

In this project, we study the problem of network function placement and
request routing under node and link constraints. With the deployment of
5G, more and more networks will benefit from mobile edge computing.
Networks can provide variety of low latency services by processing the
demands at the edge. However, the limited computation power and memory
of computing devices at the edge requires an optimal placement of the
services. An edge computing node can not provide all of the various
services and has to forward or possibly neglect some requests from
users. The limited node resources and the ability to forward the
requests to neighboring nodes naturally raises the question of where to
serve a request and how to route the request, a joint function placement
and request routing optimization problem. We formulate the problem as
mixed integer programming optimization which is known to be an *NP*-hard
problem. We solve the optimization problem using the CPLEX solver. Then,
we relax the variables to solve the optimization as a Linear
Programming. Moreover, we develop two different heuristic algorithms,
one being bottom up approach and the other being top to bottom approach.
Finally, we compare the performance and execution times of these 4
different approaches.

# System Model

We consider a MEC network consisting of a set \(\mathcal{N}\) of \(N\)
nodes (base stations) equipped with storage and computation
capabilities, a set of \(\mathcal{U}\) of \(U\) mobile users, and a set
of \(\mathcal{E}\) of \(E\) links. An example of the network is
illustrated in Fig. [1](#fig:scenario).

![](https://github.com/mustafafu/mec_request_routing/blob/master/common_script/Figures/Scenario.jpg)*Fig 1: An example scenario. User positions are generated randomly, the graph
consisting of nodes and edges is fixed over all the simulations. Blue
and red points together represents all the users, where the latter is
the users covered by access point 4 are given as an example coverage
region.*

The centralized cloud can be represented as another node $l$ where
combined with other nodes form the set $\mathcal{N} \cup \{l\}$. Each
user can access to the network through a set of access nodes
$\mathcal{N}_u$. If the request of user u determined to be served in the
network then, one of the connections between user $u$ and nodes
$\mathcal{N}_u$ should be active. The MEC network receives service
requests from its subscribers in a stochastic manner. Without the loss
of generality, we assume each user request one service
$s_u \in \mathcal{S}$ where the set $\mathcal{S}$ contains the library
of services offered in this particular MEC network. If a user performs
multiple requests, we can split it into multiple users. Each of these
services can require different computation power, storage space on the
computation nodes. Moreover a service can require to transfer data
between the user and serving computing node hence consumes bandwidth.
Generally the services offered by 5G-NR, such as autonomous driving,
AR/VR and tactile internet, can tolerate up to a certain latency. These
requirements of a service $s$ on computation power, storage space
(memory), bandwidth (traffic volume), latency are given as $\bar{c}_s$,
$\bar{m}_s$, $\bar{h}_s$, and $\bar{t}_s$, respectively. A mobile
network operator can price this various services as $w_s$, which can
model how much a user can be charged for service $s$. Notice that this
price is independent of user, however, without increasing the problem
complexity, an MNO can selectively price its users.

The request of user $u$ can be routed to any node on the edge network.
The memory and computation resources required by the service will be
reserved on the node. The request can, also, be served at the
centralized cloud where the memory and computational constrains are no
longer a system limitation. However, accessing the centralized cloud may
cause high end to end latency due to its long distance. The latency
requirement of the service should be satisfied when the request is
decided to be served at the cloud. Notice that the service will still
use the available bandwidths on the network.

The network operator needs to decide whether to serve a user at the edge
network, at the centralized cloud or ignore the service request if it
can not satisfy the requirements of the service. If the network operator
decides to serve the user, it needs to allocate the service on a node,
and also use a path through one of the access node of that user.

# Reproduce our Results
To reproduce our experiment locally follow the steps below.

```
*	git clone https://github.com/mustafafu/mec_request_routing.git
*	cd common_script
```
The matlab file, ScenarioGenerator.m generates one random instance of simulation parameters, then this instance can be solved by using lp.run and mip.run ampl scripts.

In order to solve multiple instances of linear programming and integer programming, simply use "run_mip_lp.sh" bash script as follows
```
chmod 755 run_mip_lp.sh
./run_mip_lp.sh $start $end
```
where start and end are integer values for the range of simulation instance. As an example

```
./run_mip_lp.sh 10 15
```
will solve the instances {10,11,12,13,14,15}. This bash script will output the values of the objective function in each step.


# To run on NYU HPC
You will need an account. To run on hpc, clone the repository as previously mentioned. But this time run
```
sbatch --array=1-999 lpmip.sbatch
```
This will produce the outputs of each solution inside output folder as txt file. Moreover, the objective values achieved by each solution will be recorded in their respective .txt files in the current folder. One can use the DataProcessing script to produce the figures.



For running on local machine to get result and running time:

For LP:

run only one scenario:
```
./lp_time_cal.sh $scenario_number
```
where return the result and running time. For example:
```
./lp_time_cal.sh 500
```
will return result and running time of scenario 500.



run on multi-input:
```
./lp_time_cal.sh $start $end
```
where save the result and running time to ./Output/. For example:
```
./lp_time_cal.sh 200 300
```
will save result and running time from scenario 200 to 300 to ./Output/



For MIP:

run only one scenario:
```
./lp_time_cal.sh $scenario_number
```
where return the result and running time. For example:
```
./mip_time_cal.sh 500
```
will return result and running time of scenario 500.



run on multi-input:
```
./mip_time_cal.sh $start $end
```
where save the result and running time to ./Output/. For example:
```
./mip_time_cal.sh 200 300
```
will save result and running time from scenario 200 to 300 to ./Output/





For Heuristic2:

first cd to ./Greedy2 directory
```
cd ./Greedy2
```
then like LP and MIP

run only one scenario:
```
./auto2.sh $scenario_number
```
where return the result and running time. For example:
```
./auto2.sh 500
```
will return result and running time of scenario 500.



run on multi-input:
```
./more_users_auto.sh $start $end
```
where save the result and running time to ../Output/. For example:
```
./more_users_auto.sh 200 300
```
will save result and running time from scenario 200 to 300 to ../Output/
























