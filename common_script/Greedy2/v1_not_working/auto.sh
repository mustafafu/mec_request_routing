#!/bin/bash
iter=$1

module load python3/intel/3.6.3

cp ./semi_mip.run ./iter_runs/"semi_mip_${iter}.run"
cp ./semi_mip_backup.mod ./iter_models/"semi_mip_${iter}.mod"

greedy2_start=`date +%s%3N`


echo "reset;
model './iter_models/semi_mip_${iter}.mod';
data '../Data/service_${iter}.dat';
option solver '/home/mustafafu/ampl_linux-intel64/cplex';
solve;
option display_round 2;
display access_indicator;
display revenue;" > "./iter_runs/semi_mip_${iter}.run"

echo "include './iter_runs/semi_mip_${iter}.run';exit;" | /home/mustafafu/ampl_linux-intel64/ampl > ../Output/greedy_output_${iter}_0.txt

echo "First LP finished"


threshold=1
zero_constraint=0
echo $flag
iteration=0

while [ "$flag" != "stop" ]
do
	flag=$(python3 auto_greedy.py $iteration $zero_constraint $threshold $iter 2>&1 > /dev/null)
	len=${#flag}
	if (($len > 6));
	then
		zero_constraint=$((zero_constraint+1))
	else
		zero_constraint=0
	fi
	cat ../Output/greedy_output_${iter}_${iteration}.txt
	iteration=$((iteration+1))
	echo "${iteration}"
	echo $flag
	echo "include './iter_runs/semi_mip_${iter}.run';exit;" | /home/mustafafu/ampl_linux-intel64/ampl > ../Output/greedy_output_${iter}_${iteration}.txt

done


greedy2_end=`date +%s%3N`
echo "Time to run $((greedy2_end-greedy2_start))"


