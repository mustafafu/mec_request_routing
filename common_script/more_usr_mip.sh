#!/bin/bash

iter=1001
endpoint=1011
step=1
#echo $iter



while (($iter < $endpoint ))
do
	echo "iter ${iter} begin"
	./mip_time_cal.sh $iter > ./Output/more_user_mip_${iter}.txt
	echo "iter ${iter} done"
	iter=$((iter+$step))
#	echo "iter ${iter} done"
done

