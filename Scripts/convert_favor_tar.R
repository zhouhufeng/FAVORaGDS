#!/usr/bin/env Rscript
# Step 5: convert one FAVOR tar.gz archive to SeqArray GDS.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L || !args[1L] %in% c("essential", "full")) {
    stop("Usage: convert_favor_tar.R <essential|full> <chromosome>")
}

dataset <- args[1L]
chromosome <- args[2L]
workdir <- Sys.getenv("WORKDIR")
if (workdir == "") stop("Set WORKDIR before running this script.")

library(GDSAnnotator)

prefix <- if (dataset == "essential") "FAVOR.Ess" else "FAVOR.Full"
tar_file <- file.path(workdir, "tar", dataset,
    sprintf("%s.Chr%s.tar.gz", prefix, chromosome))
gds_file <- file.path(workdir, "gds", dataset,
    sprintf("favor_annot_%s_chr%s.gds", dataset, chromosome))

stopifnot(file.exists(tar_file))
seqToGDS_FAVOR_tar(tar_file, gds_file,
    compress = "LZMA", use_float32 = TRUE, block_size = 100000L)

q("no")
