#!/bin/bash
# config.sh — URLs and output filenames for test data preparation.
# Source this file from prepare_test_data.sh:
#   source "$(dirname "$0")/config.sh"

# ---------------------------------------------------------------------------
# Directories
# ---------------------------------------------------------------------------
RAW_DATA_DIR="raw/legacy_1"
TEST_DATA_DIR="data/legacy_1"

# ---------------------------------------------------------------------------
# Source URLs
# ---------------------------------------------------------------------------
FASTA_URL="https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.fasta"
ANNOTATION_URL="https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.annotation.gtf.gz"

# ---------------------------------------------------------------------------
# Raw download targets  (URL → local path under RAW_DATA_DIR)
# ---------------------------------------------------------------------------
RAW_FASTA="${RAW_DATA_DIR}/Homo_sapiens_assembly38.fasta"
RAW_ANNOTATION="${RAW_DATA_DIR}/gencode.v38.annotation.gtf.gz"

# ---------------------------------------------------------------------------
# Test data outputs  (processed files written to TEST_DATA_DIR)
# ---------------------------------------------------------------------------
TEST_FASTA="${TEST_DATA_DIR}/test_genome.fasta"
TEST_FASTA_INDEX="${TEST_FASTA}.fai"
TEST_ANNOTATION="${TEST_DATA_DIR}/test_genome.gtf.gz"

# ---------------------------------------------------------------------------
# Sequence / field filters used during test data preparation
# ---------------------------------------------------------------------------

# Sequence IDs retained from the main GRCh38 FASTA and GTF
GRCH38_SEQ_IDS=(
    "chr1"   # chr1
    "chr1_GL383518v1_alt"
    "chr1_GL383519v1_alt"
    "chr1_GL383520v2_alt"
    "chr1_KI270706v1_random"
    "chr1_KI270707v1_random"
    "chr1_KI270708v1_random"
    "chr1_KI270709v1_random"
    "chr1_KI270710v1_random"
    "chr1_KI270711v1_random"
    "chr1_KI270712v1_random"
    "chr1_KI270713v1_random"
    "chr1_KI270714v1_random"
    "chr1_KI270759v1_alt"
    "chr1_KI270760v1_alt"
    "chr1_KI270761v1_alt"
    "chr1_KI270762v1_alt"
    "chr1_KI270763v1_alt"
    "chr1_KI270764v1_alt"
    "chr1_KI270765v1_alt"
    "chr1_KI270766v1_alt"
    "chr1_KI270892v1_alt"
    "chr15"   # chr15
    "chr15_GL383554v1_alt"
    "chr15_GL383555v2_alt"
    "chr15_KI270727v1_random"
    "chr15_KI270848v1_alt"
    "chr15_KI270849v1_alt"
    "chr15_KI270850v1_alt"
    "chr15_KI270851v1_alt"
    "chr15_KI270852v1_alt"
    "chr15_KI270905v1_alt"
    "chr15_KI270906v1_alt"
    "chr21"    # chr21
    "chr21_GL383578v2_alt"
    "chr21_GL383579v2_alt"
    "chr21_GL383580v2_alt"
    "chr21_GL383581v2_alt"
    "chr21_KI270872v1_alt"
    "chr21_KI270873v1_alt"
    "chr21_KI270874v1_alt"
    "chr22"   # chr22
    "chr22_GL383582v2_alt"
    "chr22_GL383583v2_alt"
    "chr22_KB663609v1_alt"
    "chr22_KI270731v1_random"
    "chr22_KI270732v1_random"
    "chr22_KI270733v1_random"
    "chr22_KI270734v1_random"
    "chr22_KI270735v1_random"
    "chr22_KI270736v1_random"
    "chr22_KI270737v1_random"
    "chr22_KI270738v1_random"
    "chr22_KI270739v1_random"
    "chr22_KI270875v1_alt"
    "chr22_KI270876v1_alt"
    "chr22_KI270877v1_alt"
    "chr22_KI270878v1_alt"
    "chr22_KI270879v1_alt"
    "chr22_KI270928v1_alt"
    "chrEBV"
)
