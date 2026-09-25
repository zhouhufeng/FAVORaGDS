#!/usr/bin/env bash
# Keep a copy of Full GDS before the in-place rsID update (Step 9).
#SBATCH --job-name=favor-backup
#SBATCH --partition=shared
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=1-00:00:00
#SBATCH --output=/n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Docs/Logs/favor-backup-%j.out

set -euo pipefail
source /n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Scripts/env.sh
mkdir -p "$WORKDIR/gds/full_pre_rsid"
cp -a "$WORKDIR"/gds/full/*.gds "$WORKDIR/gds/full_pre_rsid/"
(cd "$WORKDIR/gds/full" && ls -l *.gds) | awk '{print $5, $9}' > "$LOGS/full_gds_sizes.txt"
(cd "$WORKDIR/gds/full_pre_rsid" && ls -l *.gds) | awk '{print $5, $9}' | diff - "$LOGS/full_gds_sizes.txt"
echo "$(date) backup OK"
