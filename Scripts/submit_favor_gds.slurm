#!/usr/bin/env bash
# Step 6: convert chromosome $SLURM_ARRAY_TASK_ID. Pass --mem on the sbatch command line:
#   sbatch --mem=48G submit_favor_gds.slurm essential
#   sbatch --mem=64G submit_favor_gds.slurm full
#SBATCH --job-name=favor-gds
#SBATCH --partition=xlin
#SBATCH --array=1-22%22
#SBATCH --cpus-per-task=1
#SBATCH --time=4-00:00:00
#SBATCH --output=/n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Docs/Logs/convert/favor-gds-%x-%A_%a.out

set -euo pipefail
dataset=${1:?Usage: sbatch submit_favor_gds.slurm <essential|full>}
case "$dataset" in
  essential) ;;
  full) ;;
  *) echo "dataset must be essential or full" >&2; exit 2 ;;
esac

source /n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Scripts/env.sh
echo "$(date) start $dataset chr$SLURM_ARRAY_TASK_ID on $(hostname)"
/usr/bin/time -v Rscript --vanilla "$SCRIPTS/convert_favor_tar.R" "$dataset" "$SLURM_ARRAY_TASK_ID"
echo "$(date) end $dataset chr$SLURM_ARRAY_TASK_ID"
