#!/bin/bash

#SBATCH --mem=3GB
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/%a_%A.out
#SBATCH --error=logs/%a_%A.err

module purge

cd /scratch/$USER/AMPL/mec_request_routing/common_script/Greedy2/

mkdir -p logs

echo "$SLURM_ARRAY_TASK_ID"

./auto2_hpc.sh $SLURM_ARRAY_TASK_ID

