#!/usr/bin/env bash
# Step 3 of Docs/Plan/plan.txt: install gdsfmt, SeqArray, GDSAnnotator into $R_LIBS_USER
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$SCRIPTS/packages"

BIOC_DEVEL="https://www.bioconductor.org/packages/devel/bioc/src/contrib"
download_bioc_source() {
    package=$1
    requested=$2
    archive="${package}_${requested}.tar.gz"
    if wget --spider -q "$BIOC_DEVEL/$archive"; then
        wget --continue "$BIOC_DEVEL/$archive" >&2
    else
        available=$(wget -qO- "$BIOC_DEVEL/PACKAGES" | awk -v package="$package" '
            $0 == "Package: " package { found=1; next }
            found && /^Version: / { sub(/^Version: /, ""); print; exit }
            found && /^$/ { exit }
        ')
        [[ -n "$available" ]] || { echo "No devel version found for $package" >&2; return 1; }
        Rscript --vanilla -e '
            version <- package_version(commandArgs(TRUE))
            if (version[2L] <= version[1L]) stop("Bioconductor fallback is not newer")
        ' "$requested" "$available"
        archive="${package}_${available}.tar.gz"
        wget --continue "$BIOC_DEVEL/$archive" >&2
    fi
    printf '%s\n' "$archive"
}

gdsfmt_archive=$(download_bioc_source gdsfmt 1.49.8)
seqarray_archive=$(download_bioc_source SeqArray 1.53.2)
[[ -d GDSAnnotator ]] || git clone https://github.com/zhengxwen/GDSAnnotator.git
git -C GDSAnnotator log -1 --format='GDSAnnotator revision: %H %cd'
R CMD INSTALL -l "$R_LIBS_USER" "$gdsfmt_archive"
R CMD INSTALL -l "$R_LIBS_USER" "$seqarray_archive"
R CMD INSTALL -l "$R_LIBS_USER" GDSAnnotator

Rscript --vanilla -e '.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths())); library(GDSAnnotator); stopifnot(packageVersion("gdsfmt") >= "1.49.8", packageVersion("SeqArray") >= "1.53.2"); cat("gdsfmt ", as.character(packageVersion("gdsfmt")), "\n", sep=""); cat("SeqArray ", as.character(packageVersion("SeqArray")), "\n", sep=""); stopifnot(exists("seqToGDS_FAVOR_tar", where=asNamespace("GDSAnnotator"), inherits=FALSE))'
