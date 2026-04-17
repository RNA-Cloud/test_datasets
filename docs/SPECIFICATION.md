# Test Dataset Specification

## 1. Purpose
This repository defines reproducible, branch-scoped genomics test dataset bundles for automated workflow testing. The bundles are intentionally small enough for CI and local regression use while still exercising representative chromosome, patch, EBV, and auxiliary-reference handling.

## 2. Bundle Overview
The repository currently defines two bundles:

- `rna_cloud`: a RefSeq-based GRCh38 subset with auxiliary RNA-Cloud reference files.
- `legacy_1`: a Broad hg38 and Gencode v38 subset preserved for an older downstream contract.

Each bundle has its own configuration, preparation script, validation script, raw-cache location, and output directory.

## 3. Authoritative Implementation
If this document diverges from the scripts, the scripts are authoritative and this document must be updated.

Authoritative files:

- `config/rna_cloud.sh`
- `validate_rna_cloud_test_data.sh`
- `config/legacy_1.sh`
- `validate_legacy_1_test_data.sh`

Generation logic is implemented by:

- `prep_rna_cloud_test_data.sh`
- `prep_legacy_1_test_data.sh`

Build entry points are implemented by:

- `Makefile`

## 4. Repository Model

### 4.1 Directories
- `raw/`: cached upstream downloads for the RNA-Cloud bundle.
- `raw/legacy_1/`: cached upstream downloads for the Legacy 1 bundle.
- `data/`: generated RNA-Cloud outputs and the parent directory for Legacy 1 outputs.
- `data/legacy_1/`: generated Legacy 1 outputs.
- `docs/`: repository documentation.

### 4.2 Build entry points
- `make` or `make help`: show available targets.
- `make prep_data`: rebuild both bundles.
- `make validate_data`: validate both bundles.
- `make all`: rebuild both bundles, then validate both bundles.

## 5. Shared Operational Rules
- Outputs under `data/` are generated artefacts and must not be hand-maintained.
- `prep_rna_cloud_test_data.sh` removes `data/` before rebuilding the RNA-Cloud bundle.
- `prep_legacy_1_test_data.sh` removes `data/legacy_1/` before rebuilding the Legacy 1 bundle.
- Cached downloads are reused when the configured raw file already exists.
- Validation is local-only and operates on already prepared files.
- `make prep_data` requires `bash`, `seqkit`, `samtools`, `wget`, `gzip`, `gunzip`, `grep`, `awk`, and `mkdir`.

## 6. RNA-Cloud Bundle

### 6.1 Scope
The RNA-Cloud bundle prepares a filtered GRCh38 FASTA, filtered GRCh38 annotation, filtered assembly report, filtered CEN/PAR mask regions, filtered MANE GTF, filtered GRC fixes, plus unfiltered EBV and clinically relevant genes reference files.

### 6.2 Config and paths
Defined in `config/rna_cloud.sh`:

- Raw cache directory: `raw/`
- Output directory: `data/`

Raw-cache targets:

- `raw/GCF_000001405.40_GRCh38.p14_genomic.fna.gz`
- `raw/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz`
- `raw/GCF_000001405.40_GRCh38.p14_assembly_report.txt`
- `raw/GRCh38_major_release_seqs_for_alignment_pipelines_unmasked_cognates_of_masked_CEN_PAR.txt`
- `raw/MANE.GRCh38.v1.5.refseq_genomic.gtf.gz`
- `raw/grc_fixes.tsv`

Published outputs:

- `data/test_genome.fna.gz`
- `data/test_genome.gtf.gz`
- `data/test_assembly_report.txt`
- `data/test_CEN_PAR_mask_regions.txt`
- `data/test_EBV_genome.fna.gz`
- `data/test_EBV_genome.gtf.gz`
- `data/test_MANE.gtf.gz`
- `data/test_grc_fixes.tsv`
- `data/test_clinically_relevant_genes.tsv`

### 6.3 Upstream sources
The configured source URLs are:

- NCBI RefSeq GRCh38.p14 genomic FASTA
- NCBI RefSeq GRCh38.p14 genomic GTF
- NCBI RefSeq GRCh38.p14 assembly report
- NCBI GRCh38 CEN/PAR mask regions
- NCBI RefSeq EBV FASTA
- NCBI RefSeq EBV GTF
- NCBI MANE release 1.5 genomic GTF
- `RNA-Cloud/grc_fixes_monitoring` release `1.0.1`
- `frontier-genomics/clinically_relevant_genes` release `1.0.2`

### 6.4 Preparation behaviour
- Preparation is performed by `prep_rna_cloud_test_data.sh`.
- The script deletes `data/` before rebuilding.
- The script recreates `raw/` and `data/` as needed.
- Downloads to raw-cache targets are skipped when the target file already exists.
- EBV FASTA, EBV GTF, and clinically relevant genes are downloaded directly to their final output paths and are skipped when the output already exists.

### 6.5 Filtering contract

#### 6.5.1 GRCh38 retained RefSeq accessions
The main GRCh38 FASTA, GTF, and assembly report retain only:

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

#### 6.5.2 MANE retained chromosome names
The MANE GTF retains only:

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

#### 6.5.3 GRC retained patch names
The GRC fixes table retains only:

- `HG2512_PATCH`
- `HG1311_HG2539_PATCH`
- `HG2513_PATCH`
- `HG2219_PATCH`
- `HG2265_PATCH`
- `HG2521_PATCH`

### 6.6 File-specific generation requirements

#### 6.6.1 `data/test_genome.fna.gz`
- Input: `raw/GCF_000001405.40_GRCh38.p14_genomic.fna.gz`
- Tooling: `seqkit grep -r`
- The output contains only records whose headers begin with one of the retained RefSeq accessions.
- The output is gzip-compressed.

#### 6.6.2 `data/test_genome.gtf.gz`
- Input: `raw/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz`
- The output preserves header lines beginning with `#`.
- The output contains only records whose first column equals one of the retained RefSeq accessions.
- The output is gzip-compressed.

#### 6.6.3 `data/test_assembly_report.txt`
- Input: `raw/GCF_000001405.40_GRCh38.p14_assembly_report.txt`
- The output preserves all comment lines beginning with `#`.
- The output retains only non-comment rows whose column 7 RefSeq accession equals one of the retained RefSeq accessions.

#### 6.6.4 `data/test_CEN_PAR_mask_regions.txt`
- Input: `raw/GRCh38_major_release_seqs_for_alignment_pipelines_unmasked_cognates_of_masked_CEN_PAR.txt`
- The output preserves the first line.
- The output retains only rows where column 2 is `chr22`.

#### 6.6.5 `data/test_MANE.gtf.gz`
- Input: `raw/MANE.GRCh38.v1.5.refseq_genomic.gtf.gz`
- The output preserves header lines beginning with `#`.
- The output retains only records whose first column equals one of the retained MANE chromosome names.
- The output is gzip-compressed.

#### 6.6.6 `data/test_grc_fixes.tsv`
- Input: `raw/grc_fixes.tsv`
- The output preserves the header row.
- The output retains only rows whose column 14 equals one of the retained patch names.

#### 6.6.7 EBV outputs
- Outputs:
  - `data/test_EBV_genome.fna.gz`
  - `data/test_EBV_genome.gtf.gz`
- These files are downloaded directly from their configured source URLs.
- No subsetting is applied by the current implementation.

#### 6.6.8 Clinically relevant genes output
- Output: `data/test_clinically_relevant_genes.tsv`
- This file is downloaded directly from its configured source URL.
- No subsetting is applied by the current implementation.

### 6.7 Validation requirements
`validate_rna_cloud_test_data.sh` must pass. It currently asserts:

- every expected RNA-Cloud output exists,
- every expected output is non-empty,
- every gzip output passes `gzip -t`,
- the GRCh38 FASTA contains every retained RefSeq accession and excludes `NC_000002`,
- the GRCh38 GTF contains every retained RefSeq accession, preserves header lines, and excludes `NC_000002`,
- the assembly report preserves comment lines, contains every retained RefSeq accession, and excludes `NC_000002.12`,
- the CEN/PAR mask regions file preserves its header, contains `chr22` rows, and excludes `chr15`,
- the MANE GTF contains `chr15`, `chr22`, and `chr22_KQ759762v2_fix`, preserves header lines, excludes `chr2`, and excludes `chr22_ML143380v1_fix` because that contig is not present in MANE release 1.5,
- the GRC fixes file preserves the header, contains every retained patch, and excludes `HG2291_PATCH`,
- the EBV FASTA contains a FASTA header,
- the EBV GTF contains `NC_007605` or header lines and has at least 10 lines,
- the clinically relevant genes TSV has at least 2 lines.

## 7. Legacy 1 Bundle

### 7.1 Scope
The Legacy 1 bundle prepares a subset FASTA and subset GTF for an older hg38-based workflow contract.

### 7.2 Config and paths
Defined in `config/legacy_1.sh`:

- Raw cache directory: `raw/legacy_1/`
- Output directory: `data/legacy_1/`

Raw-cache targets:

- `raw/legacy_1/Homo_sapiens_assembly38.fasta`
- `raw/legacy_1/gencode.v38.annotation.gtf.gz`

Published outputs:

- `data/legacy_1/test_genome.fasta`
- `data/legacy_1/test_genome.fasta.fai`
- `data/legacy_1/test_genome.gtf.gz`

### 7.3 Upstream sources
The configured source URLs are:

- Broad hg38 `Homo_sapiens_assembly38.fasta`
- Gencode human release 38 annotation GTF

### 7.4 Preparation behaviour
- Preparation is performed by `prep_legacy_1_test_data.sh`.
- The script deletes `data/legacy_1/` before rebuilding.
- The script recreates `raw/legacy_1/` and `data/legacy_1/` as needed.
- Downloads are skipped when the configured raw file already exists.

### 7.5 Retained sequence identifiers
The Legacy 1 FASTA and GTF retain only the identifiers listed in `config/legacy_1.sh`:

- `chr1`
- `chr1_GL383518v1_alt`
- `chr1_GL383519v1_alt`
- `chr1_GL383520v2_alt`
- `chr1_KI270706v1_random`
- `chr1_KI270707v1_random`
- `chr1_KI270708v1_random`
- `chr1_KI270709v1_random`
- `chr1_KI270710v1_random`
- `chr1_KI270711v1_random`
- `chr1_KI270712v1_random`
- `chr1_KI270713v1_random`
- `chr1_KI270714v1_random`
- `chr1_KI270759v1_alt`
- `chr1_KI270760v1_alt`
- `chr1_KI270761v1_alt`
- `chr1_KI270762v1_alt`
- `chr1_KI270763v1_alt`
- `chr1_KI270764v1_alt`
- `chr1_KI270765v1_alt`
- `chr1_KI270766v1_alt`
- `chr1_KI270892v1_alt`
- `chr15`
- `chr15_GL383554v1_alt`
- `chr15_GL383555v2_alt`
- `chr15_KI270727v1_random`
- `chr15_KI270848v1_alt`
- `chr15_KI270849v1_alt`
- `chr15_KI270850v1_alt`
- `chr15_KI270851v1_alt`
- `chr15_KI270852v1_alt`
- `chr15_KI270905v1_alt`
- `chr15_KI270906v1_alt`
- `chr21`
- `chr21_GL383578v2_alt`
- `chr21_GL383579v2_alt`
- `chr21_GL383580v2_alt`
- `chr21_GL383581v2_alt`
- `chr21_KI270872v1_alt`
- `chr21_KI270873v1_alt`
- `chr21_KI270874v1_alt`
- `chr22`
- `chr22_GL383582v2_alt`
- `chr22_GL383583v2_alt`
- `chr22_KB663609v1_alt`
- `chr22_KI270731v1_random`
- `chr22_KI270732v1_random`
- `chr22_KI270733v1_random`
- `chr22_KI270734v1_random`
- `chr22_KI270735v1_random`
- `chr22_KI270736v1_random`
- `chr22_KI270737v1_random`
- `chr22_KI270738v1_random`
- `chr22_KI270739v1_random`
- `chr22_KI270875v1_alt`
- `chr22_KI270876v1_alt`
- `chr22_KI270877v1_alt`
- `chr22_KI270878v1_alt`
- `chr22_KI270879v1_alt`
- `chr22_KI270928v1_alt`
- `chrEBV`

### 7.6 File-specific generation requirements

#### 7.6.1 `data/legacy_1/test_genome.fasta`
- Input: `raw/legacy_1/Homo_sapiens_assembly38.fasta`
- Tooling: `seqkit grep -r`
- The output contains only records whose headers exactly match the retained Legacy 1 identifiers.
- The output is plain FASTA, not gzip-compressed.

#### 7.6.2 `data/legacy_1/test_genome.fasta.fai`
- Input: `data/legacy_1/test_genome.fasta`
- Tooling: `samtools faidx`
- The output is a FASTA index generated from the prepared Legacy 1 FASTA.
- The output contains exactly one entry for each retained Legacy 1 identifier.

#### 7.6.3 `data/legacy_1/test_genome.gtf.gz`
- Input: `raw/legacy_1/gencode.v38.annotation.gtf.gz`
- The output preserves header lines beginning with `#`.
- The output contains only records whose first column equals one of the retained Legacy 1 identifiers.
- The output is gzip-compressed.

### 7.7 Validation requirements
`validate_legacy_1_test_data.sh` must pass. It currently asserts:

- all expected Legacy 1 outputs exist,
- all expected outputs are non-empty,
- the GTF passes `gzip -t`,
- the FASTA contains every retained identifier from `config/legacy_1.sh`,
- the FASTA index contains exactly one entry for every retained identifier from `config/legacy_1.sh`,
- the GTF preserves header lines,
- the GTF contains records for `chr1`, `chr15`, `chr21`, and `chr22`.

## 8. Change Control Expectations
- Any change to source URLs, retained identifiers, output filenames, or compression format must update both generation logic and validation logic.
- Any externally visible contract change must also update `README.md`.
- New generated artefacts must not be introduced without validation coverage.
- Because consumers are branch-specific, keep each workflow’s dataset history isolated to its dedicated branch.
