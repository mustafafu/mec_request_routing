#!/bin/bash

loopstart=$1
loopend=$2

cplex_path=/scratch/mfo254/AMPL/ampl/cplex
ampl_path=/scratch/mfo254/AMPL/ampl/ampl

# run matlab with argument looplimit times,
matlab -nodisplay -nosplash -nodesktop -r "iteration_limit=[${loopstart},${loopend}];try, run('ScenarioGenerator.m'), catch, exit, end, exit"


for (( i = loopstart; i < loopend+1; i++ )); do




echo "solving integer programming ${i}"

# run the inteher programming version
	echo "reset;
model mip.mod;
data './Data/service_${i}.dat';
option solver '$cplex_path';
option cplex_options 'mipgap=1e-2 threads=1';
solve;
option display_round 2;
display server_indicator;
display access_indicator;
display link_indicator;"  > mip.run 

mip_start=`date +%s%3N`
echo "include mip.run;exit;" | $ampl_path > ./Output/mip_output_${i}.txt
mip_end=`date +%s%3N`





#run the linear programming version
echo "solving linear programming ${i}"


# run the integer programming version
	echo "reset;
model lp.mod;
data './Data/service_${i}.dat';
option solver '$cplex_path';
option cplex_options 'mipgap=1e-2 threads=1';
solve;
option display_round 2;
display server_indicator;
display access_indicator;
display link_indicator;"  > lp.run 

lp_start=`date +%s%3N`
echo "include lp.run;exit;" | $ampl_path > ./Output/lp_output_${i}.txt
lp_end=`date +%s%3N`


awk '{if ($(1) == "CPLEX") print("LP,"'${i}' "," '$((lp_end-lp_start))' "," $(NF))  >> "lp_solutions.txt"}' ./Output/lp_output_${i}.txt
awk '{if ($(1) == "CPLEX") print("MIP,"'${i}' "," '$((mip_end-mip_start))' "," $(NF))  >> "mip_solutions.txt"}' ./Output/mip_output_${i}.txt

done
