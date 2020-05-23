#!/bin/bash

iter=$1
endpoint=$2
step=1
echo $iter

while (($iter < $endpoint)) 
do
	echo "iter ${iter} begin"
	./auto2.sh $iter > ../Output/more_user_${iter}.txt
	echo "iter  ${iter} done"
	iter=$((iter+$step))
	

done

