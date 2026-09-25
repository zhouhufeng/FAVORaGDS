# Bioconductor/CRAN dependencies of SeqArray and GDSAnnotator (installed before SeqArray)
options(repos = c(CRAN = "https://cloud.r-project.org"))
lib <- Sys.getenv("R_LIBS_USER")
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager", lib = lib)
print(BiocManager::version())
BiocManager::install(c("digest", "S4Vectors", "IRanges", "GenomicRanges", "Seqinfo", "Biostrings"),
    lib = lib, update = FALSE, ask = FALSE, Ncpus = 4)
