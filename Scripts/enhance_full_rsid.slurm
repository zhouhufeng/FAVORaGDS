#!/usr/bin/env bash
# Step 9: run after BOTH Essential and Full conversions validate. Updates Full GDS in place.
# Smoke test: sbatch --array=22 enhance_full_rsid.slurm ; then: sbatch --array=1-21 enhance_full_rsid.slurm
#SBATCH --job-name=favor-rsid
#SBATCH --partition=bigmem
#SBATCH --cpus-per-task=1
#SBATCH --mem=400G
#SBATCH --time=3-00:00:00
#SBATCH --output=/n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Docs/Logs/enhance/favor-rsid-%A_%a.out

set -euo pipefail
source /n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Scripts/env.sh
echo "$(date) start chr$SLURM_ARRAY_TASK_ID on $(hostname)"
/usr/bin/time -v Rscript --vanilla "$SCRIPTS/enhance_full_rsid.R" "$SLURM_ARRAY_TASK_ID"
echo "$(date) end chr$SLURM_ARRAY_TASK_ID"
