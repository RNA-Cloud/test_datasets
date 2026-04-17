# Test Dataset Specification

## 1. Purpose
This repository defines a reproducible, branch-scoped test dataset bundle for genomics workflows. The bundle is intended to be small enough for automated testing while still exercising chromosome, patch, EBV, MANE, assembly-report, and auxiliary-reference handling.

## 2. Scope
The repository covers:
- acquisition of upstream reference files from NCBI and GitHub releases,
- deterministic subsetting of selected human reference artefacts,
- publication-ready test files under `data/`,
- local validation of those outputs.

The repository does not cover:
- downstream pipeline execution,
- metadata indexing beyond the included files,
- version pinning beyond the URLs currently defined in `config.sh`.

## 3. Authoritative implementation
The behaviour specified here is implemented by:
- `config.sh` for source URLs, output paths, and retained identifiers,
- `prep_test_data.sh` for generation logic,
- `validate_test_data.sh` for acceptance criteria.

If this document diverges from those files, the scripts are the source of truth and this document should be updated.

## 4. Repository model

### 4.1 Directories
- `raw/`: cached upstream downloads used as generation inputs.
- `data/`: generated test artefacts intended for consumers.
- `docs/`: repository documentation.

### 4.2 Build entry points
- `make prep_data`: rebuild `data/`.
- `make validate_data`: validate existing outputs in `data/`.
- `make all`: run preparation then validation.

## 5. Input sources
The system shall obtain upstream files from the URLs defined in `config.sh`:
- GRCh38 genomic FASTA
- GRCh38 genomic GTF
- GRCh38 assembly report
- GRCh38 CEN/PAR mask regions
- EBV genomic FASTA
- EBV genomic GTF
- MANE genomic GTF
- GRC fixes TSV
- clinically relevant genes TSV

The system shall write downloaded cache files into `raw/` except for assets intentionally downloaded directly to final test outputs.

## 6. Generation requirements

### 6.1 General
- Preparation shall be performed by `prep_test_data.sh`.
- The script shall remove the existing `data/` directory before rebuilding outputs.
- The script shall recreate `raw/` and `data/` as needed.
- Downloads shall be skipped when the target cache file already exists.

### 6.2 GRCh38 FASTA
- Input: `RAW_FASTA`
- Output: `data/test_genome.fna.gz`
- The output shall include only sequences whose accessions match `GRCH38_SEQ_IDS`.
- Output compression shall be gzip.

Retained accessions:
- `NC_000001.11`
- `NC_000015.10`
- `NC_000021.9`
- `NW_021160023.1`
- `NW_025791813.1`
- `NW_025791814.1`
- `NW_025791815.1`
- `NC_000022.11`
- `NW_021160026.1`
- `NW_015148969.2`

### 6.3 GRCh38 annotation GTF
- Input: `RAW_ANNOTATION`
- Output: `data/test_genome.gtf.gz`
- The output shall preserve comment lines beginning with `#`.
- The output shall include only records whose first column matches `GRCH38_SEQ_IDS`.
- Output compression shall be gzip.

### 6.4 Assembly report
- Input: `RAW_ASSEMBLY_REPORT`
- Output: `data/test_assembly_report.txt`
- The output shall preserve all header/comment lines beginning with `#`.
- The output shall include only non-comment rows whose RefSeq accession in column 7 matches `GRCH38_SEQ_IDS`.

### 6.5 CEN/PAR mask regions
- Input: `RAW_CEN_PAR_MASK_REGIONS`
- Output: `data/test_CEN_PAR_mask_regions.txt`
- The output shall preserve the first line as header.
- The output shall include only rows where column 2 equals `chr22`.

### 6.6 MANE annotation
- Input: `RAW_MANE_ANNOTATION`
- Output: `data/test_MANE.gtf.gz`
- The output shall preserve comment lines beginning with `#`.
- The output shall include only records whose first column matches `MANE_CHROMS`.
- Output compression shall be gzip.

Retained chromosome names:
- `chr1`
- `chr15`
- `chr21`
- `chr21_ML143377v1_fix`
- `chr21_MU273390v1_fix`
- `chr21_MU273391v1_fix`
- `chr21_MU273392v1_fix`
- `chr22`
- `chr22_ML143380v1_fix`
- `chr22_KQ759762v2_fix`

### 6.7 EBV reference files
- Outputs:
  - `data/test_EBV_genome.fna.gz`
  - `data/test_EBV_genome.gtf.gz`
- These files shall be downloaded directly from their configured source URLs.
- No subsetting shall be applied by the current implementation.

### 6.8 GRC fixes
- Input: `RAW_GRC_FIXES`
- Output: `data/test_grc_fixes.tsv`
- The output shall preserve the header row.
- The output shall include only records whose column 14 value matches `GRC_FIX_PATCHES`.

Retained patch names:
- `HG2512_PATCH`
- `HG1311_HG2539_PATCH`
- `HG2513_PATCH`
- `HG2219_PATCH`
- `HG2265_PATCH`
- `HG2521_PATCH`

### 6.9 Clinically relevant genes
- Output: `data/test_clinically_relevant_genes.tsv`
- This file shall be downloaded directly from its configured source URL.
- No subsetting shall be applied by the current implementation.

## 7. Output contract
Successful preparation shall produce the following files:
- `data/test_genome.fna.gz`
- `data/test_genome.gtf.gz`
- `data/test_assembly_report.txt`
- `data/test_CEN_PAR_mask_regions.txt`
- `data/test_EBV_genome.fna.gz`
- `data/test_EBV_genome.gtf.gz`
- `data/test_MANE.gtf.gz`
- `data/test_grc_fixes.tsv`
- `data/test_clinically_relevant_genes.tsv`

All gzip outputs shall be readable by `gzip -t`.
All outputs shall be non-empty.

## 8. Validation requirements
`validate_test_data.sh` defines the acceptance checks. At minimum:
- every expected output file shall exist,
- every expected output file shall be non-empty,
- every `.gz` file shall pass gzip integrity checks,
- GRCh38 FASTA shall contain each retained accession and exclude `NC_000002`,
- GRCh38 GTF shall contain each retained accession, preserve headers, and exclude `NC_000002`,
- assembly report shall preserve headers, include each retained accession, and exclude `NC_000002.12`,
- CEN/PAR mask regions shall include the header, include `chr22` records, and exclude `chr15`,
- MANE GTF shall include `chr15`, `chr22`, `chr22_KQ759762v2_fix`, preserve headers, exclude `chr2`, and exclude `chr22_ML143380v1_fix`,
- GRC fixes shall include the retained patches, preserve the header, and exclude `HG2291_PATCH`,
- EBV GTF shall contain either `NC_007605` records or header lines and have at least 10 lines,
- clinically relevant genes TSV shall contain at least 2 lines.

## 9. Operational constraints
- `make prep_data` requires internet access when source files are not already cached.
- `make prep_data` requires `seqkit`, `wget`, `awk`, `grep`, `gzip`, `gunzip`, and `bash`.
- `make validate_data` is expected to run without network access when outputs already exist.
- Consumers should treat this repository as branch-specific test data, not a canonical production reference source.

## 10. Change control expectations
- Any change to retained accessions, chromosome names, patch names, source URLs, or output filenames shall update both generation and validation logic.
- Any change to the downstream consumption contract should also update `README.md`.
- New generated artefacts should not be introduced without corresponding validation coverage.
