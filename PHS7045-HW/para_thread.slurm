#!/bin/bash
#SBATCH --job-name=simulation      # Job name
#SBATCH --output=simulation_%A_%a.out  # Standard output log (%A for job ID, %a for task ID)
#SBATCH --error=simulation_%A_%a.err   # Standard error log
#SBATCH --array=1-20                # Array of jobs (1 to 10)
#SBATCH --ntasks=1                  # Number of tasks per job
#SBATCH --cpus-per-task=1           # Number of CPUs per task
#SBATCH --mem=4G                    # Memory per node
#SBATCH --time=02:00:00             # Time limit
#SBATCH --partition=notchpeak-guest # Partition
#SBATCH --account=owner-guest
# Load R module (adjust as per your HPC environment)
module load R

# Set parameters
n_jobs=20      # Total number of jobs
n_trials=100000 # Total number of trials

# Run the R script
Rscript para_thread.R $SLURM_ARRAY_TASK_ID $n_jobs $n_trials

