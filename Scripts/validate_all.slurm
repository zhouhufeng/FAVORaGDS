#!/usr/bin/env bash
# Step 7: validate GDS for both datasets. Usage: sbatch validate_all.slurm <tag>
# Manifests go to Docs/Logs/favor_<dataset>_gds_manifest_<tag>.tsv
#SBATCH --job-name=favor-validate
#SBATCH --partition=shared
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=0-06:00:00
#SBATCH --output=/n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Docs/Logs/favor-validate-%j.out

set -euo pipefail
tag=${1:?Usage: sbatch validate_all.slurm <tag>}
source /n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Scripts/env.sh
for dataset in essential full; do
  Rscript --vanilla "$SCRIPTS/validate_favor_gds.R" "$dataset"
  mv "$LOGS/favor_${dataset}_gds_manifest.tsv" "$LOGS/favor_${dataset}_gds_manifest_${tag}.tsv"
done
# Essential and Full must have identical variant counts per chromosome
paste <(cut -f1,2 "$LOGS/favor_essential_gds_manifest_${tag}.tsv") <(cut -f2 "$LOGS/favor_full_gds_manifest_${tag}.tsv") |
  awk 'NR>1 && $2!=$3 {print "Variant-count mismatch chr"$1": "$2" vs "$3; bad=1} END {exit bad}'
echo "$(date) validation $tag OK"
