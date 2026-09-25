# Source this before running any FAVOR->GDS step.
export PROJECT=/n/holystore01/LABS/xlin/Lab/zhouhufeng/projects/Computing/FAVORaGDS
export WORKDIR="$PROJECT/Data"          # tar/ and gds/ live here
export SCRIPTS="$PROJECT/Scripts"
export LOGS="$PROJECT/Docs/Logs"
export R_LIBS_USER="$SCRIPTS/R_libs"
export TAR=/usr/bin/tar
module load R/4.6.1-fasrc01 >/dev/null 2>&1
