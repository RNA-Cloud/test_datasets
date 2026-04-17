#!/bin/bash
# prepare_test_data.sh — downloads and prepares Legacy 1 test data.
# All URLs and filenames are defined in config.sh.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/legacy_1.sh"

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

        # Declare an empty array to hold the pattern arguments
        local patterns=()

        # Loop over every element in GRCH38_SEQ_IDS
        # The [@] expands to all elements, quotes preserve any whitespace in values
        for id in "${GRCH38_SEQ_IDS[@]}"; do
            # += appends to the array; each iteration adds two elements:
            # the flag "-p" and its value "^<id>" (^ means "starts with" in regex)
            patterns+=(-p "^${id}$")
        done

        # "${patterns[@]}" expands the array as separate arguments (e.g. -p "^chr1" -p "^chr2" ...)
        # The | (pipe) passes seqkit's output directly to gzip without a temp file
        # gzip -c writes compressed output to stdout, which > redirects into TEST_FASTA
        seqkit grep -r "${patterns[@]}" "${RAW_FASTA}" > "${TEST_FASTA}"
    fi

    if [ ! -f "${TEST_FASTA_INDEX}" ]; then
        echo "🏃 Preparing FASTA index file..."
        samtools faidx "${TEST_FASTA}"
    fi
}

function prepare_test_annotation() {
    echo "🏃 Preparing test GTF file..."
    if [ ! -f "${TEST_ANNOTATION}" ]; then

        # Build an awk condition string that matches any of the sequence IDs.
        # Start with a condition to always pass through comment lines (lines where
        # the first field starts with #)
        local awk_condition='$1~/^#/'

        # Loop over every element in GRCH38_SEQ_IDS and append an OR condition
        # for each ID. awk's || is a logical OR, and $1 refers to the first
        # tab-delimited field (the chromosome name in a GTF file)
        for id in "${GRCH38_SEQ_IDS[@]}"; do
            awk_condition+=" || \$1==\"${id}\""
        done

        # gunzip -c decompresses to stdout without deleting the original file
        # awk -F"\t" sets the field separator to tab (GTF files are tab-delimited)
        # The awk condition is passed as a string; matching lines are printed by default
        # gzip -c compresses the filtered output, which > redirects into TEST_ANNOTATION
        gunzip -c "${RAW_ANNOTATION}" \
            | awk -F"\t" "${awk_condition}" \
            | gzip -c > "${TEST_ANNOTATION}"
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

echo "✅ Test data preparation complete."
