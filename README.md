# Joint Service Placement and Request Routing in Multi Connectivity Enabled Mobile Edge Networks


To reproduce our experiment follow the steps below.

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
