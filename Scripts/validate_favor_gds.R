#!/usr/bin/env Rscript
# Step 7: open each GDS, check format/core nodes, write size manifest to Docs/Logs.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L || !args[1L] %in% c("essential", "full")) {
    stop("Usage: validate_favor_gds.R <essential|full>")
}

dataset <- args[1L]
workdir <- Sys.getenv("WORKDIR")
if (workdir == "") stop("Set WORKDIR before running this script.")
logdir <- Sys.getenv("LOGS", workdir)

library(gdsfmt)
prefix <- if (dataset == "essential") "FAVOR.Ess" else "FAVOR.Full"
result <- lapply(1:22, function(chromosome) {
    source_file <- file.path(workdir, "tar", dataset,
        sprintf("%s.Chr%d.tar.gz", prefix, chromosome))
    gds_file <- file.path(workdir, "gds", dataset,
        sprintf("favor_annot_%s_chr%d.gds", dataset, chromosome))
    stopifnot(file.exists(source_file), file.exists(gds_file))
    gds <- openfn.gds(gds_file, readonly = TRUE)
    stopifnot(identical(get.attr.gdsn(gds$root)$FileFormat, "SEQ_ARRAY"))
    for (node in c("variant.id", "position", "chromosome", "allele", "annotation/info")) {
        stopifnot(!is.null(index.gdsn(gds, node, silent = TRUE)))
    }
    n_variant <- objdesp.gdsn(index.gdsn(gds, "variant.id"))$dim
    closefn.gds(gds)
    data.frame(
        chromosome = chromosome,
        variants = n_variant,
        source_file = basename(source_file),
        source_bytes = file.info(source_file)$size,
        source_GiB = file.info(source_file)$size / 2^30,
        gds_file = basename(gds_file),
        gds_bytes = file.info(gds_file)$size,
        gds_GiB = file.info(gds_file)$size / 2^30
    )
})

manifest <- do.call(rbind, result)
manifest[c("source_GiB", "gds_GiB")] <- lapply(
    manifest[c("source_GiB", "gds_GiB")], round, digits = 2)
output_file <- file.path(logdir, sprintf("favor_%s_gds_manifest.tsv", dataset))
write.table(manifest, output_file, sep = "\t", row.names = FALSE, quote = FALSE)
print(manifest, row.names = FALSE)
