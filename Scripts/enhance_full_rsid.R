#!/usr/bin/env Rscript
# Step 9: copy annotation/id (rsID) from Essential GDS into matching Full GDS, keyed by position+allele.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
    stop("Usage: enhance_full_rsid.R <chromosome>")
}

chromosome <- as.integer(args[1L])
if (is.na(chromosome) || chromosome < 1L || chromosome > 22L) {
    stop("Chromosome must be an integer from 1 to 22.")
}

workdir <- Sys.getenv("WORKDIR")
if (workdir == "") stop("Set WORKDIR before running this script.")

essential_file <- file.path(workdir, "gds", "essential",
    sprintf("favor_annot_essential_chr%d.gds", chromosome))
full_file <- file.path(workdir, "gds", "full",
    sprintf("favor_annot_full_chr%d.gds", chromosome))
stopifnot(file.exists(essential_file), file.exists(full_file))

library(gdsfmt)
library(SeqArray)

essential <- NULL
full <- NULL
on.exit({
    if (!is.null(essential)) try(seqClose(essential), silent = TRUE)
    if (!is.null(full)) try(seqClose(full), silent = TRUE)
}, add = TRUE)

essential <- seqOpen(essential_file, readonly = TRUE)
full <- seqOpen(full_file, readonly = TRUE)

essential_count <- objdesp.gdsn(index.gdsn(essential, "variant.id"))$dim
full_count <- objdesp.gdsn(index.gdsn(full, "variant.id"))$dim
if (essential_count != full_count) {
    stop(sprintf("Chr%d variant-count mismatch: Essential=%d, Full=%d",
        chromosome, essential_count, full_count))
}

essential_position <- seqGetData(essential, "position")
full_position <- seqGetData(full, "position")
essential_allele <- seqGetData(essential, "allele")
full_allele <- seqGetData(full, "allele")
essential_key <- paste(essential_position, essential_allele, sep = ":")
full_key <- paste(full_position, full_allele, sep = ":")
rm(essential_position, full_position, essential_allele, full_allele); invisible(gc())

if (anyDuplicated(essential_key) || anyDuplicated(full_key)) {
    stop(sprintf("Chr%d contains a duplicate position/allele key", chromosome))
}

essential_index <- match(full_key, essential_key)
if (anyNA(essential_index) || anyDuplicated(essential_index)) {
    stop(sprintf("Chr%d position/allele key sets differ", chromosome))
}
rm(essential_key, full_key); invisible(gc())

essential_rsid <- seqGetData(essential, "annotation/id")
essential_nonempty <- sum(!is.na(essential_rsid) & nzchar(essential_rsid))
mapped_rsid <- essential_rsid[essential_index]
rm(essential_rsid, essential_index); invisible(gc())

seqClose(essential)
essential <- NULL
seqClose(full)
full <- NULL

full <- seqOpen(full_file, readonly = FALSE)
seqAddValue(full, "annotation/id", mapped_rsid, replace = TRUE)
seqClose(full)
full <- NULL
cleanup.gds(full_file)

# Post-check: Full now carries the same number of non-empty rsIDs as Essential
full <- seqOpen(full_file, readonly = TRUE)
full_rsid <- seqGetData(full, "annotation/id")
seqClose(full)
full <- NULL
full_nonempty <- sum(!is.na(full_rsid) & nzchar(full_rsid))
message(sprintf("Chr%d: non-empty rsID Essential=%d Full=%d", chromosome,
    essential_nonempty, full_nonempty))
if (full_nonempty != essential_nonempty) stop("rsID count mismatch after update")

message(sprintf("Chr%d: annotation/id added to %s", chromosome, full_file))
