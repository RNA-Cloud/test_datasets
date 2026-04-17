#!/bin/bash
# config.sh — URLs and output filenames for test data preparation.
# Source this file from prepare_test_data.sh:
#   source "$(dirname "$0")/config.sh"

# ---------------------------------------------------------------------------
# Directories
# ---------------------------------------------------------------------------
RAW_DATA_DIR="raw"
TEST_DATA_DIR="data"

# ---------------------------------------------------------------------------
# Source URLs
# ---------------------------------------------------------------------------
FASTA_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.fna.gz"
ANNOTATION_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz"
ASSEMBLY_REPORT_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_assembly_report.txt"
CEN_PAR_MASK_REGIONS_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GRCh38_major_release_seqs_for_alignment_pipelines/unmasked_cognates_of_masked_CEN_PAR.txt"
EBV_FASTA_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/402/265/GCF_002402265.1_ASM240226v1/GCF_002402265.1_ASM240226v1_genomic.fna.gz"
EBV_ANNOTATION_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/402/265/GCF_002402265.1_ASM240226v1/GCF_002402265.1_ASM240226v1_genomic.gtf.gz"
MANE_ANNOTATION_URL="https://ftp.ncbi.nlm.nih.gov/refseq/MANE/MANE_human/release_1.5/MANE.GRCh38.v1.5.refseq_genomic.gtf.gz"
GRC_FIXES_URL="https://github.com/RNA-Cloud/grc_fixes_monitoring/releases/download/1.0.1/grc_fixes.tsv"
CLINICALLY_RELEVANT_GENES_URL="https://github.com/frontier-genomics/clinically_relevant_genes/releases/download/1.0.2/results.tsv"

# ---------------------------------------------------------------------------
# Raw download targets  (URL → local path under RAW_DATA_DIR)
# ---------------------------------------------------------------------------
RAW_FASTA="${RAW_DATA_DIR}/GCF_000001405.40_GRCh38.p14_genomic.fna.gz"
RAW_ANNOTATION="${RAW_DATA_DIR}/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz"
RAW_ASSEMBLY_REPORT="${RAW_DATA_DIR}/GCF_000001405.40_GRCh38.p14_assembly_report.txt"
RAW_CEN_PAR_MASK_REGIONS="${RAW_DATA_DIR}/GRCh38_major_release_seqs_for_alignment_pipelines_unmasked_cognates_of_masked_CEN_PAR.txt"
RAW_MANE_ANNOTATION="${RAW_DATA_DIR}/MANE.GRCh38.v1.5.refseq_genomic.gtf.gz"
RAW_GRC_FIXES="${RAW_DATA_DIR}/grc_fixes.tsv"

# ---------------------------------------------------------------------------
# Test data outputs  (processed files written to TEST_DATA_DIR)
# ---------------------------------------------------------------------------
TEST_FASTA="${TEST_DATA_DIR}/test_genome.fna.gz"
TEST_ANNOTATION="${TEST_DATA_DIR}/test_genome.gtf.gz"
TEST_ASSEMBLY_REPORT="${TEST_DATA_DIR}/test_assembly_report.txt"
TEST_CEN_PAR_MASK_REGIONS="${TEST_DATA_DIR}/test_CEN_PAR_mask_regions.txt"
TEST_EBV_FASTA="${TEST_DATA_DIR}/test_EBV_genome.fna.gz"
TEST_EBV_ANNOTATION="${TEST_DATA_DIR}/test_EBV_genome.gtf.gz"
TEST_MANE_ANNOTATION="${TEST_DATA_DIR}/test_MANE.gtf.gz"
TEST_GRC_FIXES="${TEST_DATA_DIR}/test_grc_fixes.tsv"
TEST_CLINICALLY_RELEVANT_GENES="${TEST_DATA_DIR}/test_clinically_relevant_genes.tsv"

# ---------------------------------------------------------------------------
# Sequence / field filters used during test data preparation
# ---------------------------------------------------------------------------

# Sequence IDs retained from the main GRCh38 FASTA and GTF
GRCH38_SEQ_IDS=(
    "NC_000001.11"   # chr1
    "NC_000015.10"   # chr15
    "NC_000021.9"    # chr21
    "NW_021160023.1" # chr21_ML143377v1_fix patch
    "NW_025791813.1" # chr21_MU273390v1_fix patch
    "NW_025791814.1" # chr21_MU273391v1_fix patch
    "NW_025791815.1" # chr21_MU273392v1_fix patch
    "NC_000022.11"   # chr22
    "NW_021160026.1" # chr22_ML143380v1_fix patch
    "NW_015148969.2" # chr22_KQ759762v2_fix patch
)

# Chromosome names used in the MANE GTF (UCSC-style)
MANE_CHROMS=(
    "chr1"
    "chr15"
    "chr21"
    "chr21_ML143377v1_fix"
    "chr21_MU273390v1_fix"
    "chr21_MU273391v1_fix"
    "chr21_MU273392v1_fix"
    "chr22"
    "chr22_ML143380v1_fix"
    "chr22_KQ759762v2_fix"
)

# Patch names retained from grc_fixes.tsv (column 14)
GRC_FIX_PATCHES=(
    "HG2512_PATCH"
    "HG1311_HG2539_PATCH"
    "HG2513_PATCH"
    "HG2219_PATCH"
    "HG2265_PATCH"
    "HG2521_PATCH"
)