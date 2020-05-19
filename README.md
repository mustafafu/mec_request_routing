# Latency Focused Function Placement and Request Routing in Multi Access Mobile Edge Computing Networks

In this project, we study the problem of network function placement and request routing under node and link constraints. With the deployment of 5G, more and more networks will benefit from mobile edge computing. Networks can provide variety of low latency services by processing the demands at the edge. However, the limited computation power and memory of computing devices at the edge requires an optimal placement of the services. An edge computing node can not provide all of the various services and has to forward or possibly neglect some requests from users. The limited node resources and the ability to forward the requests to neighboring nodes naturally raises the question of where to serve a request and how to route the request, a joint function placement and request routing optimization problem. We formulate the problem as mixed integer programming optimization which is known to be an \emph{NP}-hard problem. We solve the optimization problem using the CPLEX solver. Then, we relax the variables to solve the optimization as a Linear Programming. Moreover, we develop two different heuristic algorithms, one being bottom up approach and the other being top to bottom approach. Finally, we compare the performance and execution times of these 4 different approaches.





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
