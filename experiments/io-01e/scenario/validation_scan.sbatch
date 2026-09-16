#!/usr/bin/env bash
#SBATCH --job-name=io01e-validate
#SBATCH --account=rc-help
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G
#SBATCH --time=00:20:00
#SBATCH --output=validation-%j.out
#SBATCH --error=validation-%j.err

set -euo pipefail

export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

python3 validate_candidate.py \
    --evidence MEASURED-EVIDENCE.md \
    --expected-files 12000
