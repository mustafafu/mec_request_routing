#!/bin/bash

loopstart=$1
loopend=$2

# run matlab with argument looplimit times,
matlab -nodisplay -nosplash -nodesktop -r "iteration_limit=[${loopstart},${loopend}];try, run('ScenarioGenerator.m'), catch, exit, end, exit"


for (( i = loopstart; i < loopend+1; i++ )); do
	
#run the linear programming version
echo 'solving linear programming' $i


# run the inteher programming version
	echo "reset;
model lp.mod;
data './Data/service_${i}.dat';
option solver '/home/mustafafu/ampl_linux-intel64/cplex';
solve;
display server_indicator;
display access_indicator;
display link_indicator;"  > lp.run 

echo "include lp.run;exit;" | /home/mustafafu/ampl_linux-intel64/ampl > ./Output/lp_output_${i}.txt




echo 'solving integer programming' $i

# run the inteher programming version
	echo "reset;
model mip.mod;
data './Data/service_${i}.dat';
option solver '/home/mustafafu/ampl_linux-intel64/cplex';
solve;
display server_indicator;
display access_indicator;
display link_indicator;"  > mip.run 


echo "include mip.run;exit;" | /home/mustafafu/ampl_linux-intel64/ampl > ./Output/mip_output_${i}.txt





echo 'Integer Programming Solution'
cat ./Output/mip_output_${i}.txt | grep objective
echo 'Linear Programming Solution'
cat ./Output/lp_output_${i}.txt | grep objective
done


