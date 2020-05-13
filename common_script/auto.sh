#!/bin/bash
echo "include semi_mip.run;exit;" | ../ampl_linux-intel64/ampl > ./Output/greedy_output.txt


threshold=0.85
zero_constraint=0
echo $flag
iteration=0

while [ "$flag" != "stop" ]
do
	echo "include semi_mip.run;exit;" | ../ampl_linux-intel64/ampl > ./Output/greedy_output.txt
	flag=$(python3 auto_greedy.py $iteration $zero_constraint $threshold 2>&1 > /dev/null)
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
#cp ./semi_mip_backup.mod ./semi_mip.mod
