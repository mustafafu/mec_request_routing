#!/bin/bash
echo "include semi_mip.run;exit;" | ../ampl_linux-intel64/ampl > ./Output/greedy_output.txt
#flag=$(python3 ./auto_greedy.py 0)
flag=$(python3 auto_greedy.py 0 2>&1 > /dev/null)
iteration=1
#zero="0"
#while ["$flag" != "$zero"]
while [ "$flag" != "stop" ]
do
	echo "include semi_mip.run;exit;" | ../ampl_linux-intel64/ampl > ./Output/greedy_output.txt
	flag=$(python3 auto_greedy.py $iteration 2>&1 > /dev/null)
#	$(python3 ./auto_greedy.py $iteration)
	iteration=$((iteration+1))
	echo $flag
#	echo "include lp.run;exit;" | ../ampl_linux-intel64/ampl > ./Output/greedy_output.txt
done

