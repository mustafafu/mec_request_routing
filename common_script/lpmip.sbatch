#!/bin/bash

#SBATCH --mem=3GB
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/%a_%A.out
#SBATCH --error=logs/%a_%A.err

module purge
module load matlab/2019a

cd /scratch/$USER/AMPL/mec_request_routing/common_script/

mkdir -p logs

echo "$SLURM_ARRAY_TASK_ID"

./run_mip_lp.sh $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_ID
