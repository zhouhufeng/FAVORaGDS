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
- rsID step runs on `sapphire` 400G (bigmem requires >1000G); adds post-check that Full non-empty rsID count equals Essential (`enhance_full_rsid.slurm`); frees intermediate vectors early.

## Job history
| Date | Job | What |
| --- | --- | --- |
| 2026-09-25 | 48370541 | download Essential chr1-22 |
| 2026-09-25 | 48370542 | download Full chr1-22 |
| 2026-09-25 | 48370814 | smoke test convert Essential chr22 (afterok download) |
| 2026-09-25 | 48370815 | smoke test convert Full chr22 (afterok download) |
| 2026-09-25 | 48370943 | convert Essential chr1-21 (afterok 48370814 + aftercorr 48370541) |
| 2026-09-25 | 48370972 | convert Full chr1-21 (afterok 48370815 + aftercorr 48370542) |
| 2026-09-25 | 48378318 | validate both, tag pre_rsid (afterok all conversions) |
| 2026-09-25 | 48378325 | backup Full GDS -> Data/gds/full_pre_rsid (afterok 48378318) |
| 2026-09-25 | 48378360 | rsID smoke test chr22, sapphire 400G (afterok backup) |
| 2026-09-25 | 48378361 | rsID chr1-21 %4 (afterok 48378360) |
| 2026-09-25 | 48378362 | validate both, tag post_rsid, mail on END/FAIL (afterok 48378361) |

## Remaining steps
Whole pipeline is chained in Slurm; any failure cancels downstream jobs (--kill-on-invalid-dep). Check with
`sacct -u $USER -S 2026-09-25 --name=favor-dl,favor-gds-ess,favor-gds-full,favor-validate,favor-backup,favor-rsid -X`.
1. Review with user: manifests `Docs/Logs/favor_*_gds_manifest_{pre,post}_rsid.tsv` vs plan section 8; logs in Docs/Logs.
2. Only after user approval: upload to Harvard Dataverse (target not yet chosen). Then delete Data/gds/full_pre_rsid if not needed.

## Dataverse upload (pending)
- API token stored in `Docs/Secret/dataverse_api_token` (mode 600, dir 700, git-ignored). Never commit or echo it.
- Target dataset/collection: to be confirmed by user before upload.
