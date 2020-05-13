#!/bin/bash
iter=$1

cp ./semi_mip_backup.mod ./semi_mip_${iter}.mod

greedy2_start=`date +%s%3N`


echo "reset;
model semi_mip_${iter}.mod;
data '../Data/service_${iter}.dat';
option solver '../ampl_linux-intel64/cplex';
solve;
option display_round 2;
display access_indicator;
display revenue;" > semi_mip_${iter}.run

echo "include semi_mip_${iter}.run;exit;" | ../ampl_linux-intel64/ampl > ../Output/greedy_output_${iter}.txt



threshold=0.85
zero_constraint=0
echo $flag
iteration=0

while [ "$flag" != "stop" ]
do
	echo "include semi_mip_${iter}.run;exit;" | ../ampl_linux-intel64/ampl > ../Output/greedy_output_${iter}.txt
	flag=$(python3 auto_greedy.py $iteration $zero_constraint $threshold $iter 2>&1 > /dev/null)
	len=${#flag}
	if (($len > 6));
	then
		zero_constraint=$((zero_constraint+1))
	else
		zero_constraint=0
	fi
	iteration=$((iteration+1))
	echo $flag

done


greedy2_end=`date +%s%3N`
echo "Time to run $((greedy2_end-greedy2_start))"


