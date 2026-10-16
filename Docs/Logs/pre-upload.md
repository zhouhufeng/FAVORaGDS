# FAVOR GDS pre-upload summary

Checked 2026-10-16. Sources: `favor_{essential,full}_gds_manifest_post_rsid.tsv`, Slurm logs in this folder,
Dataverse native API. Sizes in GiB (2^30 bytes) unless stated.

## Pipeline status
All steps completed; no FAVOR jobs queued.

| Step | Job | Result |
| --- | --- | --- |
| Backup compare `full/` vs `full_pre_rsid/` | 50548667 | `cmp OK: 22 files identical` |
| rsID smoke test chr22 | 50548668 | COMPLETED (8.5 min) |
| rsID chr1-21 | 50548681 | COMPLETED (9.5-55 min each) |
| Validate both, tag post_rsid | 50548683 | `validation post_rsid OK` (2026-10-05 07:13) |

rsID check: for all 22 chromosomes, non-empty rsID count in Full equals Essential
(e.g. chr22: 15,787,512 = 15,787,512).

## Upload size
| Dataset | GDS bytes | GDS GiB | Source tar.gz GiB | Variants |
| --- | --- | --- | --- | --- |
| Essential | 100,982,626,672 | 94.05 | 370.5 | 8,345,712,008 |
| Full | 220,086,453,829 | 204.97 | 633.1 | 8,345,712,008 |
| **Total** | **321,069,080,501** | **299.02** | 1,003.6 | |

GDS is ~3.4x smaller than the tar.gz archives. Not uploaded: `Data/gds/full_pre_rsid` (201G backup).

## Per-chromosome sizes
Variant counts are identical between Essential and Full for every chromosome.

| Chr | Variants | Essential tar.gz | Essential GDS | Full tar.gz | Full GDS | GDS total |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 697,723,257 | 31.16 | 7.94 | 53.75 | 17.37 | 25.32 |
| 2 | 728,249,325 | 32.54 | 8.31 | 55.61 | 18.08 | 26.40 |
| 3 | 599,657,406 | 26.63 | 6.77 | 45.30 | 14.68 | 21.46 |
| 4 | 574,493,843 | 25.25 | 6.39 | 42.82 | 13.74 | 20.13 |
| 5 | 548,653,509 | 24.22 | 6.14 | 41.19 | 13.28 | 19.42 |
| 6 | 514,950,784 | 22.99 | 5.83 | 39.10 | 12.64 | 18.47 |
| 7 | 481,465,078 | 21.24 | 5.38 | 36.09 | 11.66 | 17.04 |
| 8 | 438,236,670 | 19.41 | 4.94 | 33.06 | 10.71 | 15.65 |
| 9 | 368,668,774 | 16.32 | 4.12 | 27.97 | 9.01 | 13.13 |
| 10 | 403,649,527 | 18.01 | 4.58 | 30.96 | 10.08 | 14.65 |
| 11 | 407,232,600 | 18.18 | 4.62 | 31.13 | 10.11 | 14.73 |
| 12 | 403,205,116 | 18.00 | 4.59 | 30.87 | 10.08 | 14.67 |
| 13 | 296,684,670 | 13.11 | 3.31 | 22.42 | 7.23 | 10.54 |
| 14 | 274,216,494 | 12.20 | 3.10 | 20.92 | 6.81 | 9.92 |
| 15 | 256,275,016 | 11.31 | 2.87 | 19.40 | 6.32 | 9.18 |
| 16 | 247,862,947 | 11.16 | 2.86 | 19.17 | 6.28 | 9.14 |
| 17 | 251,209,815 | 11.30 | 2.86 | 19.40 | 6.33 | 9.19 |
| 18 | 242,369,265 | 10.49 | 2.62 | 17.67 | 5.53 | 8.15 |
| 19 | 177,368,363 | 7.99 | 2.04 | 13.72 | 4.51 | 6.55 |
| 20 | 193,559,674 | 8.64 | 2.19 | 14.86 | 4.82 | 7.01 |
| 21 | 121,352,389 | 5.15 | 1.28 | 8.83 | 2.81 | 4.09 |
| 22 | 118,627,486 | 5.19 | 1.30 | 8.91 | 2.89 | 4.19 |
| **Total** | **8,345,712,008** | **370.5** | **94.05** | **633.1** | **204.97** | **299.02** |

Largest single file: `favor_annot_full_chr2.gds`, 18.08 GiB -> use direct S3 upload (uploadurls API / DVUploader).

## Internal compression
- `Scripts/convert_favor_tar.R:23`: `compress = "LZMA", use_float32 = TRUE, block_size = 100000L`.
- Node-level check on chr22 (`objdesp.gdsn`):

| File | Data nodes | Codec | Stored | Uncompressed | Ratio |
| --- | --- | --- | --- | --- | --- |
| `favor_annot_essential_chr22.gds` | 37 | all `LZMA_RA.def:256K` | 1.28 | 22.81 | ~18x |
| `favor_annot_full_chr22.gds` | 191 | 189 `LZMA_RA`, 2 `ZIP_RA` | 2.66 | 69.21 | ~26x |

- The 2 `ZIP_RA` nodes in Full (`refseq_category`, `refseq_info`) are empty (16 bytes); irrelevant.
- rsID node `annotation/id`, rewritten in the rsID step, is still LZMA_RA.
- Random-access (`_RA`) compression: regions can be read without decompressing whole files.
- Files are already compressed; re-zipping before upload would gain little.

## Dataverse quota (collection `favor`, checked 2026-10-16)
| | Bytes | Size |
| --- | --- | --- |
| Quota | 2,748,779,069,440 | 2.50 TiB |
| Used | 3,299,305,633,466 | 3.00 TiB (~513 GiB over quota) |
| GDS to upload | 321,069,080,501 | 299 GiB |
| Needed after upload | ~3,620,374,714,000 | 3.62 TB / 3.29 TiB |

BLOCKER: quota unchanged since 2026-10-04; uploads refused until Harvard Dataverse support raises it.
Suggested request: 4 TB (~3.64 TiB) for headroom.

Targets (new versions alongside SQL/ and CSV/): Essential -> doi:10.7910/DVN/1VGTJI, Full -> doi:10.7910/DVN/KFUBKG.

## Before upload
1. User review of this summary and the post_rsid manifests (required before any Dataverse upload).
2. Quota increase from Harvard Dataverse support.
3. Upload via direct S3; afterwards delete `Data/gds/full_pre_rsid` if not needed.
