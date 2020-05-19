#!/bin/bash

cplex_path=/home/mustafafu/ampl_linux-intel64/cplex
ampl_path=/home/mustafafu/ampl_linux-intel64/ampl

for i in 9	33	34	39	43	48	49	50	53	62	63	65	67	103	111	114	119	121	125	136	139	159	167	169	206	208	262	280	286	294	296	297	320	322	344	345	346	364	366	367	368	369	378	383	386	395	404	405	436	440	447	455	459	461	462	463	464	465	466	467	470	499	505	506	539	555	568	593	600	612	615	625	629	665	670	674	683	688	691	692	693	698	699	703	704	705	718	719	720	721	722	724	727	738	739	743	744	745	747	748	749	752	753	754	756	762	763	771	775	779	782	785	813	814	816	817	859	860	863	893	895	896	897	899	900; do

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

awk '{if ($(1) == "CPLEX") print("MIP,"'${i}' "," '$((mip_end-mip_start))' "," $(NF))  >> "rerun_mip_solutions.txt"}' ./Output/mip_output_${i}.txt

done
