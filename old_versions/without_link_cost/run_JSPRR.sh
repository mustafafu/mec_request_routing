#!/bin/bash
for iteration in {1..10}; do
matlab -nodisplay -nosplash -nodesktop -r "AI = '${iteration}';try, run('ScenarioGenerator.m'), catch, exit, end, exit"

    echo "reset;
model JSPRR.mod;
data './Data/service_${iteration}.dat';
option solver '/home/mustafafu/ampl_linux-intel64/cplex';
solve;
display x;
display y;
display u;" > JSPRR.run

echo "include JSPRR.run;" | /home/mustafafu/ampl_linux-intel64/ampl | tee ./Output/lp_output_${iteration}.txt
echo "exit;"


echo "reset;
model JSPRR_mip.mod;
data './Data/service_${iteration}.dat';
option solver '/home/mustafafu/ampl_linux-intel64/cplex';
solve;
display x;
display y;
display u;" > JSPRR_mip.run

echo "include JSPRR_mip.run;" | /home/mustafafu/ampl_linux-intel64/ampl | tee ./Output/mip_output_${iteration}.txt
echo "exit;"
done
