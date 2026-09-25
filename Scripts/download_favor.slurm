#!/usr/bin/env bash
# Step 4: download + validate one FAVOR archive. Usage: sbatch download_favor.slurm <essential|full>
# Array task ID = chromosome; Dataverse file IDs come from favor_datafiles.tsv.
#SBATCH --job-name=favor-dl
#SBATCH --partition=shared
#SBATCH --array=1-22%6
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=1-00:00:00
#SBATCH --output=/n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Docs/Logs/download/favor-dl-%A_%a.out

set -euo pipefail
source /n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS/Scripts/env.sh
dataset=${1:?Usage: sbatch download_favor.slurm <essential|full>}
chromosome=$SLURM_ARRAY_TASK_ID
fileid=$(awk -v d="$dataset" -v c="$chromosome" '$1==d && $2==c {print $3}' "$SCRIPTS/favor_datafiles.tsv")
[[ -n "$fileid" ]] || { echo "No file ID for $dataset chr$chromosome"; exit 2; }
prefix=$([[ $dataset == essential ]] && echo FAVOR.Ess || echo FAVOR.Full)
out="$WORKDIR/tar/$dataset/$prefix.Chr$chromosome.tar.gz"
echo "$(date) $dataset chr$chromosome datafile $fileid -> $out"

for attempt in 1 2 3 4 5; do
  wget --continue --progress=dot:giga -O "$out" "https://dataverse.harvard.edu/api/access/datafile/$fileid" && break
  echo "wget attempt $attempt failed; retrying in 60s"; sleep 60
done

$TAR -tzf "$out" > "$out.members" || { echo "Corrupt: $out"; exit 1; }
grep -Eiq '\.csv$' "$out.members" || { echo "No CSV member: $out"; exit 1; }
echo "$(date) OK $out $(stat -c %s "$out") bytes, $(grep -Eic '\.csv$' "$out.members") CSV members"
