#!/bin/bash
# prepare_test_data.sh — downloads and prepares RNA-Cloud test data.
# All URLs and filenames are defined in config.sh.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

function download_file() {
    local url=$1
    local output_path=$2
    if [ ! -f "${output_path}" ]; then
        echo "⬇️ Downloading ${url}..."
        wget -qc -O "${output_path}" "${url}"
    fi
}

function prepare_test_fasta() {
    echo "🏃 Preparing test FASTA file..."
    if [ ! -f "${TEST_FASTA}" ]; then
        seqkit grep -r \
            -p "^${GRCH38_SEQ_IDS[0]}" \
            -p "^${GRCH38_SEQ_IDS[1]}" \
            -p "^${GRCH38_SEQ_IDS[2]}" \
            -p "^${GRCH38_SEQ_IDS[3]}" \
            -p "^${GRCH38_SEQ_IDS[4]}" \
            -p "^${GRCH38_SEQ_IDS[5]}" \
            -p "^${GRCH38_SEQ_IDS[6]}" \
            -p "^${GRCH38_SEQ_IDS[7]}" \
            -p "^${GRCH38_SEQ_IDS[8]}" \
            "${RAW_FASTA}" \
            | gzip -c > "${TEST_FASTA}"
    fi
}

function prep_test_assembly_report() {
    echo "🏃 Preparing test assembly report..."
    if [ ! -f "${TEST_ASSEMBLY_REPORT}" ]; then
        grep '^#' "${RAW_ASSEMBLY_REPORT}" > "${TEST_ASSEMBLY_REPORT}"
        grep -v '^#' "${RAW_ASSEMBLY_REPORT}" \
            | awk -F"\t" \
                '$7 == "'"${GRCH38_SEQ_IDS[0]}"'" ||
                 $7 == "'"${GRCH38_SEQ_IDS[1]}"'" ||
                 $7 == "'"${GRCH38_SEQ_IDS[2]}"'" ||
                 $7 == "'"${GRCH38_SEQ_IDS[3]}"'" ||
                 $7 == "'"${GRCH38_SEQ_IDS[4]}"'" ||
                 $7 == "'"${GRCH38_SEQ_IDS[5]}"'" ||
                 $7 == "'"${GRCH38_SEQ_IDS[6]}"'" ||
                 $7 == "'"${GRCH38_SEQ_IDS[7]}"'" ||
                 $7 == "'"${GRCH38_SEQ_IDS[8]}"'"' \
            >> "${TEST_ASSEMBLY_REPORT}"
    fi
}

function prepare_test_annotation() {
    echo "🏃 Preparing test GTF file..."
    if [ ! -f "${TEST_ANNOTATION}" ]; then
        gunzip -c "${RAW_ANNOTATION}" \
            | awk -F"\t" \
                '$1~/^#/ ||
                 $1=="'"${GRCH38_SEQ_IDS[0]}"'" ||
                 $1=="'"${GRCH38_SEQ_IDS[1]}"'" ||
                 $1=="'"${GRCH38_SEQ_IDS[2]}"'" ||
                 $1=="'"${GRCH38_SEQ_IDS[3]}"'" ||
                 $1=="'"${GRCH38_SEQ_IDS[4]}"'" ||
                 $1=="'"${GRCH38_SEQ_IDS[5]}"'" ||
                 $1=="'"${GRCH38_SEQ_IDS[6]}"'" ||
                 $1=="'"${GRCH38_SEQ_IDS[7]}"'" ||
                 $1=="'"${GRCH38_SEQ_IDS[8]}"'"' \
            | gzip -c > "${TEST_ANNOTATION}"
    fi
}

function prepare_test_cen_par_mask_regions() {
    echo "🏃 Preparing test CEN/PAR mask regions file..."
    if [ ! -f "${TEST_CEN_PAR_MASK_REGIONS}" ]; then
        awk -F"\t" '$2=="chr22"' "${RAW_CEN_PAR_MASK_REGIONS}" \
            > "${TEST_CEN_PAR_MASK_REGIONS}"
    fi
}

function prepare_test_mane_annotation() {
    echo "🏃 Preparing test MANE GTF file..."
    if [ ! -f "${TEST_MANE_ANNOTATION}" ]; then
        gunzip -c "${RAW_MANE_ANNOTATION}" \
            | awk -F"\t" \
                '$1~/^#/ ||
                 $1=="'"${MANE_CHROMS[0]}"'" ||
                 $1=="'"${MANE_CHROMS[1]}"'" ||
                 $1=="'"${MANE_CHROMS[2]}"'" ||
                 $1=="'"${MANE_CHROMS[3]}"'" ||
                 $1=="'"${MANE_CHROMS[4]}"'" ||
                 $1=="'"${MANE_CHROMS[5]}"'" ||
                 $1=="'"${MANE_CHROMS[6]}"'" ||
                 $1=="'"${MANE_CHROMS[7]}"'" ||
                 $1=="'"${MANE_CHROMS[8]}"'"' \
            | gzip -c > "${TEST_MANE_ANNOTATION}"
    fi
}

function prepare_test_grc_fixes() {
    echo "🏃 Preparing test GRC fixes file..."
    if [ ! -f "${TEST_GRC_FIXES}" ]; then
        awk -F"\t" \
            '$14=="'"${GRC_FIX_PATCHES[0]}"'" || 
             $14=="'"${GRC_FIX_PATCHES[1]}"'" ||
             $14=="'"${GRC_FIX_PATCHES[2]}"'" ||
             $14=="'"${GRC_FIX_PATCHES[3]}"'" ||
             $14=="'"${GRC_FIX_PATCHES[4]}"'" ||
             $14=="'"${GRC_FIX_PATCHES[5]}"'"' \
            "${RAW_GRC_FIXES}" > "${TEST_GRC_FIXES}"
    fi
}

# ---------------------------------------------------------------------------

echo "🏁 Preparing test data..."

echo "Cleaning up old test data..."
rm -rf "${TEST_DATA_DIR}"

echo "Creating directories..."
mkdir -p "${RAW_DATA_DIR}"
mkdir -p "${TEST_DATA_DIR}"

download_file "${FASTA_URL}"                "${RAW_FASTA}"
prepare_test_fasta

download_file "${ANNOTATION_URL}"           "${RAW_ANNOTATION}"
prepare_test_annotation

download_file "${ASSEMBLY_REPORT_URL}"      "${RAW_ASSEMBLY_REPORT}"
prep_test_assembly_report

download_file "${CEN_PAR_MASK_REGIONS_URL}" "${RAW_CEN_PAR_MASK_REGIONS}"
prepare_test_cen_par_mask_regions

download_file "${MANE_ANNOTATION_URL}"      "${RAW_MANE_ANNOTATION}"
prepare_test_mane_annotation

download_file "${EBV_FASTA_URL}"            "${TEST_EBV_FASTA}"
download_file "${EBV_ANNOTATION_URL}"       "${TEST_EBV_ANNOTATION}"

download_file "${GRC_FIXES_URL}"            "${RAW_GRC_FIXES}"
prepare_test_grc_fixes

download_file "${CLINICALLY_RELEVANT_GENES_URL}" "${TEST_CLINICALLY_RELEVANT_GENES}"

echo "✅ Test data preparation complete."