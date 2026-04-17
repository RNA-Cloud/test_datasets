# Test Datasets

Shell-based fixture builder for small branch-scoped genomics reference bundles used in automated testing.

The repository currently builds two dataset bundles:

- `rna_cloud`: RefSeq-based GRCh38 subset plus assembly report, CEN/PAR mask regions, MANE, EBV, GRC fixes, and clinically relevant genes.
- `legacy_1`: Broad hg38 FASTA subset plus Gencode v38 annotation subset for an older downstream contract.

> [!WARNING]
> Do not merge test data branches to `main`. Keep each workflow or consumer on its own dedicated branch.

## Repository Layout

| Path | Role |
| --- | --- |
| `Makefile` | Operator entry points: `make help`, `make prep_data`, `make validate_data`, `make all` |
| `config/rna_cloud.sh` | Canonical RNA-Cloud source URLs, cache paths, output paths, and retained identifiers |
| `config/legacy_1.sh` | Canonical Legacy 1 source URLs, cache paths, output paths, and retained identifiers |
| `prep_rna_cloud_test_data.sh` | Rebuilds the RNA-Cloud dataset under `data/` |
| `validate_rna_cloud_test_data.sh` | Validates the RNA-Cloud dataset contract |
| `prep_legacy_1_test_data.sh` | Rebuilds the Legacy 1 dataset under `data/legacy_1/` |
| `validate_legacy_1_test_data.sh` | Validates the Legacy 1 dataset contract |
| `raw/` | Cached upstream downloads reused across runs |
| `data/` | Generated outputs for consumers; treat as build artefacts |

## Prerequisites

- `bash`
- `seqkit`
- `wget`
- `gzip` and `gunzip`
- `grep`
- `awk`
- `mkdir`

Network access is required for `make prep_data` when required cache files are missing or when a file is downloaded directly to its final output path.

## Usage

Show available targets:

```bash
make
```

Prepare both bundles:

```bash
make prep_data
```

Validate both bundles:

```bash
make validate_data
```

Prepare then validate:

```bash
make all
```

## Build Behaviour

- `make prep_data` runs `./prep_rna_cloud_test_data.sh` and then `./prep_legacy_1_test_data.sh`.
- `prep_rna_cloud_test_data.sh` deletes and recreates `data/` before rebuilding RNA-Cloud outputs.
- `prep_legacy_1_test_data.sh` deletes and recreates `data/legacy_1/` before rebuilding Legacy 1 outputs.
- Cached downloads are stored in `raw/` for RNA-Cloud and `raw/legacy_1/` for Legacy 1 where the scripts define a raw target.
- RNA-Cloud downloads EBV FASTA, EBV GTF, and clinically relevant genes directly to `data/`; they are not cached by the current build logic.
- Validation is local-only and checks the already-prepared files in `data/`.

## RNA-Cloud Bundle

Prepared outputs:

- `data/test_genome.fna.gz`
- `data/test_genome.gtf.gz`
- `data/test_assembly_report.txt`
- `data/test_CEN_PAR_mask_regions.txt`
- `data/test_EBV_genome.fna.gz`
- `data/test_EBV_genome.gtf.gz`
- `data/test_MANE.gtf.gz`
- `data/test_grc_fixes.tsv`
- `data/test_clinically_relevant_genes.tsv`

Current upstream sources are defined in [`config/rna_cloud.sh`](/Users/hjos9586/Projects/test_datasets/config/rna_cloud.sh). The bundle is built from:

- NCBI RefSeq GRCh38.p14 genomic FASTA
- NCBI RefSeq GRCh38.p14 genomic GTF
- NCBI RefSeq GRCh38.p14 assembly report
- NCBI GRCh38 CEN/PAR mask regions
- NCBI RefSeq EBV FASTA and GTF
- NCBI MANE release 1.5 genomic GTF
- `RNA-Cloud/grc_fixes_monitoring` release `1.0.1`
- `frontier-genomics/clinically_relevant_genes` release `1.0.2`

Filtering rules:

- Main GRCh38 FASTA and GTF retain only the RefSeq accessions listed in `GRCH38_SEQ_IDS`.
- Assembly report retains all comment lines plus rows whose RefSeq accession in column 7 matches `GRCH38_SEQ_IDS`.
- CEN/PAR mask regions retain the header and only rows where column 2 is `chr22`.
- MANE retains headers plus only the chromosome names listed in `MANE_CHROMS`.
- GRC fixes retain the header plus only rows whose column 14 patch name matches `GRC_FIX_PATCHES`.
- EBV FASTA, EBV GTF, and clinically relevant genes are downloaded as-is.

## Legacy 1 Bundle

Prepared outputs:

- `data/legacy_1/test_genome.fasta`
- `data/legacy_1/test_genome.fasta.fai`
- `data/legacy_1/test_genome.gtf.gz`

Current upstream sources are defined in [`config/legacy_1.sh`](/Users/hjos9586/Projects/test_datasets/config/legacy_1.sh). The bundle is built from:

- Broad hg38 `Homo_sapiens_assembly38.fasta`
- Gencode human release 38 annotation GTF

Filtering rules:

- FASTA retains only the chromosome and alt/random contig identifiers listed in `config/legacy_1.sh`.
- GTF retains comment lines plus only records whose first column matches those same identifiers.
- The FASTA output is plain text `.fasta`; the annotation output is gzip-compressed `.gtf.gz`.

## Validation Contract

The validation scripts are the executable specification:

- [`validate_rna_cloud_test_data.sh`](/Users/hjos9586/Projects/test_datasets/validate_rna_cloud_test_data.sh) checks file existence, non-emptiness, gzip integrity where applicable, expected retained identifiers, and spot-check exclusions for the RNA-Cloud bundle.
- [`validate_legacy_1_test_data.sh`](/Users/hjos9586/Projects/test_datasets/validate_legacy_1_test_data.sh) checks file existence, non-emptiness, gzip integrity for the GTF, presence of all retained FASTA contigs, and presence of key chromosomes in the GTF for the Legacy 1 bundle.

## RNA-Cloud `sources.json` Example

The configuration below can be used by an RNA-Cloud genome reference workflow after replacing the branch name with the branch that contains your prepared data.

```json
{
  "genome": {
    "provider": "NCBI Refseq",
    "fasta_url": "https://github.com/RNA-Cloud/test_datasets/raw/refs/heads/<branch-name>/data/test_genome.fna.gz",
    "annotation_url": "https://github.com/RNA-Cloud/test_datasets/raw/refs/heads/<branch-name>/data/test_genome.gtf.gz",
    "assembly_report": "https://github.com/RNA-Cloud/test_datasets/raw/refs/heads/<branch-name>/data/test_assembly_report.txt",
    "assembly_report_comment_lines": 63,
    "cen_par_mask_regions": "https://github.com/RNA-Cloud/test_datasets/raw/refs/heads/<branch-name>/data/test_CEN_PAR_mask_regions.txt",
    "ebv_fasta_url": "https://github.com/RNA-Cloud/test_datasets/raw/refs/heads/<branch-name>/data/test_EBV_genome.fna.gz",
    "ebv_annotation_url": "https://github.com/RNA-Cloud/test_datasets/raw/refs/heads/<branch-name>/data/test_EBV_genome.gtf.gz",
    "refseq_mane_annotation_url": "https://github.com/RNA-Cloud/test_datasets/raw/refs/heads/<branch-name>/data/test_MANE.gtf.gz"
  },
  "reference": {
    "grc_fixes": "https://github.com/RNA-Cloud/test_datasets/raw/refs/heads/<branch-name>/data/test_grc_fixes.tsv",
    "clinically_relevant_genes": "https://github.com/RNA-Cloud/test_datasets/raw/refs/heads/<branch-name>/data/test_clinically_relevant_genes.tsv"
  },
  "rRNA": {
    "NC_000021": "reference/rRNA/NC_000021.9_45S.gtf"
  },
  "ncbi_assembly_masked_regions": {
    "chr15_KN538374v1_fix": "reference/ncbi_assembly_masked_regions/chr15_KN538374v1_fix.bed"
  },
  "gnomad": {
    "reference": "data/gnomad/GRCh38/gnomad_r4_freq.tsv.gz",
    "freq": 0.1,
    "hemizygote_count": 100,
    "homozygote_count": 100
  }
}
```
