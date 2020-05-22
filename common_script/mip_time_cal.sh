#!/bin/bash

iter=$1
echo $iter

echo "reset;
model mip.mod;
data './Data/service_${iter}.dat';
option solver '../../ampl_linux-intel64/cplex';
option cplex_options 'mipgap=1e-2 threads=1';
solve;
display access_indicator;
display revenue;" > "./mip.run"



greedy2_start=`date +%s%3N`

../../ampl_linux-intel64/ampl ./mip.run

greedy2_end=`date +%s%3N`
echo "Time to run $((greedy2_end-greedy2_start))"

