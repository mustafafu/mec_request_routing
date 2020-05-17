#!/bin/bash
iter=$1

module load python3/intel/3.6.3


cplex_path=/home/mustafafu/ampl_linux-intel64/cplex
ampl_path=/home/mustafafu/ampl_linux-intel64/ampl


cp ./semi_mip.run ./iter_runs/"semi_mip_${iter}.run"
cp ./semi_mip_backup.mod ./iter_models/"semi_mip_${iter}.mod"

greedy2_start=`date +%s%3N`



echo "reset;
model './iter_models/semi_mip_${iter}.mod';
data '../Data/service_${iter}.dat';
option solver '$cplex_path';
option cplex_options 'mipgap=1e-2 threads=1';
solve;
option display_round 2;
display access_indicator;
display revenue;" > "./iter_runs/semi_mip_${iter}.run"

echo "include './iter_runs/semi_mip_${iter}.run';exit;" | $ampl_path > ../Output/greedy_output_${iter}_0.txt

echo "First Step finished"

threshold=1
zero_constraint=0
echo $flag
iteration=0

while [ "$flag" != "stop" ]
do
	flag=$(python3 greedy2.py $iteration $zero_constraint $threshold $iter 2>&1 > /dev/null)
	len=${#flag}
	if (($len > 15));
	then
		zero_constraint=$((zero_constraint+1))
	else
		zero_constraint=0
	fi
	
	iteration=$((iteration+1))
	echo "${iteration}"
	echo $flag
	echo "include './iter_runs/semi_mip_${iter}.run';exit;" | $ampl_path > ../Output/greedy_output_${iter}_${iteration}.txt
	cat ../Output/greedy_output_${iter}_${iteration}.txt
done


greedy2_end=`date +%s%3N`
echo "Time to run $((greedy2_end-greedy2_start))"


awk '{if ($(1) == "CPLEX") print("GD2,"'${iter}' "," '$((greedy2_end-greedy2_start))' "," $(NF))  >> "../gdv2_solutions.txt"}' ../Output/greedy_output_${iter}_${iteration}.txt