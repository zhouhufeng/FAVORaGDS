# FAVOR tar.gz -> GDS run log

Plan: `Docs/Plan/plan.txt`. All commands: `source Scripts/env.sh` first.

## Layout
| Path | Content |
| --- | --- |
| `Data/` (= `$WORKDIR`) | `tar/{essential,full}` archives, `gds/{essential,full}` outputs |
| `Scripts/` | env.sh, R/Slurm scripts, `packages/` sources, `R_libs/` |
| `Docs/Logs/` | install logs, `download/`, `convert/`, `enhance/` Slurm logs, GDS manifests |

## Environment
- Cluster: FASRC Cannon, `module load R/4.6.1-fasrc01` (Bioconductor 3.23)
- gdsfmt 1.49.8 (requested version)
- SeqArray 1.53.3 (1.53.2 no longer on Bioc devel; newer fallback per plan)
- GDSAnnotator git f5e543696f9032c421fd3d837f1d43b6f3b3cfae (2026-08-28)
- Deps installed via BiocManager (`Scripts/install_deps.R`): digest, S4Vectors, IRanges, GenomicRanges, Seqinfo, Biostrings
- Storage: group xlin quota 830T, 812.4T used at start (~17.6T free); both datasets need ~1.3T

## Deviations from plan
- WORKDIR = `Data/`; scripts in `Scripts/`, R_libs in `Scripts/R_libs`, logs/manifests in `Docs/Logs/`.
- Validation: plan's `get.attr.gdsn(gds$root, "FileFormat")` is invalid (function takes one arg); uses `get.attr.gdsn(gds$root)$FileFormat`. Removed on.exit double-close. Manifest also records variant count.
- Downloads run as Slurm arrays (`download_favor.slurm`, partition shared, %6), with retries and tar -tzf / CSV check per archive (member lists saved as `*.members`).
- Conversion on partition `xlin` (30-day limit) since Full needs up to 4 days; `--mem` passed on sbatch command line.
- rsID step runs on `bigmem` 400G (`enhance_full_rsid.slurm`); frees intermediate vectors early.

## Job history
| Date | Job | What |
| --- | --- | --- |
| 2026-09-25 | 48370541 | download Essential chr1-22 |
| 2026-09-25 | 48370542 | download Full chr1-22 |
| 2026-09-25 | 48370814 | smoke test convert Essential chr22 (afterok download) |
| 2026-09-25 | 48370815 | smoke test convert Full chr22 (afterok download) |
| 2026-09-25 | 48370943 | convert Essential chr1-21 (afterok 48370814 + aftercorr 48370541) |
| 2026-09-25 | 48370972 | convert Full chr1-21 (afterok 48370815 + aftercorr 48370542) |

## Remaining steps
1. (Submitted, chained automatically.) If smoke test fails, dependent arrays are cancelled (--kill-on-invalid-dep); fix and resubmit.
2. `Rscript --vanilla Scripts/validate_favor_gds.R essential|full` -> `Docs/Logs/favor_*_gds_manifest.tsv`; compare with plan section 8.
3. rsID: `sbatch --array=22 Scripts/enhance_full_rsid.slurm`, then 1-21 (optionally snapshot `Data/gds/full` first).

## Dataverse upload (pending)
- API token stored in `Secrets/dataverse_api_token` (mode 600, dir 700, git-ignored). Never commit or echo it.
- Target dataset/collection: to be confirmed by user before upload.
