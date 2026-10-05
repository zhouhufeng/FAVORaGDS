# FAVORaGDS

Convert the public GRCh38 FAVOR **Essential** and **Full** annotation archives (Harvard Dataverse, CSV tar.gz) into one SeqArray GDS file per autosome with `GDSAnnotator::seqToGDS_FAVOR_tar()`, then copy rsIDs from Essential into Full.

Sources: Essential DOI [10.7910/DVN/1VGTJI](https://doi.org/10.7910/DVN/1VGTJI), Full DOI [10.7910/DVN/KFUBKG](https://doi.org/10.7910/DVN/KFUBKG).

## Layout
| Path | Content |
| --- | --- |
| `Scripts/` | pipeline scripts (below) |
| `Docs/Plan/plan.txt` | full runbook |
| `Docs/RunLog.md` | environment, job IDs, deviations from the runbook |
| `Data/` | archives and GDS output (not tracked) |

## Pipeline
All steps assume `source Scripts/env.sh` (sets `WORKDIR=Data`, `R_LIBS_USER=Scripts/R_libs`, loads `R/4.6.1-fasrc01`). Edit `PROJECT` in `env.sh` and the `#SBATCH` paths/partitions for another cluster.

| Step | Command |
| --- | --- |
| 1. Install R packages | `Rscript --vanilla Scripts/install_deps.R && Scripts/install_packages.sh` |
| 2. Download + check archives | `sbatch Scripts/download_favor.slurm essential` / `full` |
| 3. Convert to GDS | `sbatch --mem=48G Scripts/submit_favor_gds.slurm essential`; `sbatch --mem=64G Scripts/submit_favor_gds.slurm full` |
| 4. Validate + size manifest | `Rscript --vanilla Scripts/validate_favor_gds.R essential` / `full` |
| 5. Add rsID to Full | `sbatch --array=1-22 Scripts/enhance_full_rsid.slurm` |

Run chr22 first as a smoke test (`--array=22`) before submitting all chromosomes.

## Software
gdsfmt 1.49.8, SeqArray 1.53.3, GDSAnnotator `f5e5436`, R 4.6.1 / Bioconductor 3.23.

## Expected size and runtime (reference run, chr1-22)
| Dataset | tar.gz | GDS | Longest chromosome |
| --- | ---: | ---: | ---: |
| Essential | 370.5 GiB | 94.1 GiB | 14.3 h (chr2) |
| Full | 633.1 GiB | 200.4 GiB | 50.7 h (chr2) |

## Status (2026-10-04)
| Stage | State |
| --- | --- |
| Download + archive checks, chr1-22 | done |
| Convert to GDS (Essential 95G, Full 201G) | done |
| Validate before rsID | done 2026-09-30 (`Docs/Logs/favor_*_gds_manifest_pre_rsid.tsv`) |
| Backup Full -> `Data/gds/full_pre_rsid` | copied; byte compare running |
| Add rsID to Full (chr22 smoke test, then chr1-21) | queued behind the compare |
| Validate after rsID | queued |
| Review with maintainer | pending |
| Dataverse upload | blocked on collection storage quota |

## Plan
1. Finish the chained Slurm jobs: backup compare -> rsID chr22 -> rsID chr1-21 -> validate after rsID. Job IDs are in `Docs/RunLog.md`.
2. Review manifests before and after rsID (sizes, variant counts, Essential vs Full, rsID filled in) against `Docs/Plan/plan.txt` section 8.
3. Request a storage quota increase for the `favor` Dataverse collection (2.5 TiB quota, 3.0 TiB used; GDS adds about 296 GiB).
4. After approval, upload GDS as a new version of the existing datasets, next to the `SQL/` and `CSV/` folders:
   Essential -> [10.7910/DVN/1VGTJI](https://doi.org/10.7910/DVN/1VGTJI), Full -> [10.7910/DVN/KFUBKG](https://doi.org/10.7910/DVN/KFUBKG).
5. Remove `Data/gds/full_pre_rsid` once the upload is verified.
