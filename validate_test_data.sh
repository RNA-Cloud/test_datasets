#!/bin/bash
# test_data_preparation.sh — verifies that all expected test data outputs exist
# and contain the correct sequences / fields.
#
# Usage:
#   bash test_data_preparation.sh
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
PASS=0
FAIL=0

pass() { echo "  ✅ PASS: $1"; ((PASS++)) || true; }
fail() { echo "  ❌ FAIL: $1"; ((FAIL++)) || true; }

section() { echo; echo "━━━ $1 ━━━"; }

assert_file_exists() {
    local file="$1"
    if [ -f "${file}" ]; then
        pass "File exists: ${file}"
    else
        fail "File missing: ${file}"
    fi
}

assert_file_nonempty() {
    local file="$1"
    if [ -s "${file}" ]; then
        pass "File is non-empty: ${file}"
    else
        fail "File is empty: ${file}"
    fi
}

# Check that a gzipped file can be decompressed without error
assert_gz_valid() {
    local file="$1"
    if gzip -t "${file}" 2>/dev/null; then
        pass "Valid gzip: ${file}"
    else
        fail "Corrupt gzip: ${file}"
    fi
}

# Assert that a string is present in a file (plain or gzipped)
assert_contains() {
    local file="$1"
    local pattern="$2"
    local label="${3:-${pattern}}"
    local found
    if [[ "${file}" == *.gz ]]; then
        found=$(gunzip -c "${file}" 2>/dev/null | grep -c "${pattern}" || true)
    else
        found=$(grep -c "${pattern}" "${file}" || true)
    fi
    if [ "${found}" -gt 0 ]; then
        pass "Contains '${label}': ${file}"
    else
        fail "Missing '${label}': ${file}"
    fi
}

# Assert that a string is NOT present in a file
assert_not_contains() {
    local file="$1"
    local pattern="$2"
    local label="${3:-${pattern}}"
    local found
    if [[ "${file}" == *.gz ]]; then
        found=$(gunzip -c "${file}" 2>/dev/null | grep -c "${pattern}" || true)
    else
        found=$(grep -c "${pattern}" "${file}" || true)
    fi
    if [ "${found}" -eq 0 ]; then
        pass "Correctly excludes '${label}': ${file}"
    else
        fail "Should not contain '${label}': ${file}"
    fi
}

# Assert minimum line count (plain or gzipped)
assert_min_lines() {
    local file="$1"
    local min="$2"
    local count
    if [[ "${file}" == *.gz ]]; then
        count=$(gunzip -c "${file}" 2>/dev/null | wc -l)
    else
        count=$(wc -l < "${file}")
    fi
    if [ "${count}" -ge "${min}" ]; then
        pass "Line count ${count} >= ${min}: ${file}"
    else
        fail "Line count ${count} < ${min} (expected at least ${min}): ${file}"
    fi
}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

echo "🧪 RNA-Cloud test data verification"
echo "   Config sourced from: ${SCRIPT_DIR}/config.sh"

# ── 1. File existence & integrity ──────────────────────────────────────────
section "1. File existence & integrity"

for var in \
    TEST_FASTA TEST_ANNOTATION TEST_ASSEMBLY_REPORT \
    TEST_CEN_PAR_MASK_REGIONS TEST_EBV_FASTA TEST_EBV_ANNOTATION \
    TEST_MANE_ANNOTATION TEST_GRC_FIXES TEST_CLINICALLY_RELEVANT_GENES; do
    file="${!var}"
    assert_file_exists   "${file}"
    assert_file_nonempty "${file}"
    [[ "${file}" == *.gz ]] && assert_gz_valid "${file}"
done

# ── 2. GRCh38 FASTA — correct sequences retained ───────────────────────────
section "2. GRCh38 test FASTA"

for seq_id in "${GRCH38_SEQ_IDS[@]}"; do
    assert_contains "${TEST_FASTA}" "^>${seq_id}" "${seq_id}"
done

# chr1 should NOT be present
assert_not_contains "${TEST_FASTA}" "^>NC_000001" "NC_000001 (chr1, should be absent)"

# ── 3. GRCh38 GTF — correct chromosomes, header preserved ──────────────────
section "3. GRCh38 test GTF"

for seq_id in "${GRCH38_SEQ_IDS[@]}"; do
    assert_contains "${TEST_ANNOTATION}" "^${seq_id}	" "${seq_id}"
done

assert_contains     "${TEST_ANNOTATION}" "^#" "GTF header lines"
assert_not_contains "${TEST_ANNOTATION}" "^NC_000001	" "NC_000001 (chr1, should be absent)"

# ── 4. Assembly report — header lines + correct sequences ──────────────────
section "4. Assembly report"

assert_contains "${TEST_ASSEMBLY_REPORT}" "^#" "header comment lines"
for seq_id in "${GRCH38_SEQ_IDS[@]}"; do
    assert_contains "${TEST_ASSEMBLY_REPORT}" "${seq_id}" "${seq_id}"
done
# chr1 accession should not appear
assert_not_contains "${TEST_ASSEMBLY_REPORT}" "NC_000001.11" "NC_000001.11 (chr1, should be absent)"

# ── 5. CEN/PAR mask regions — only chr22 entries ───────────────────────────
section "5. CEN/PAR mask regions"

assert_contains     "${TEST_CEN_PAR_MASK_REGIONS}" "	chr22	\|	chr22$" "chr22 entries"
assert_not_contains "${TEST_CEN_PAR_MASK_REGIONS}" "	chr15	"          "chr15 (should be absent)"

# ── 6. MANE annotation — correct chromosomes retained ──────────────────────
section "6. MANE annotation GTF"

assert_contains     "${TEST_MANE_ANNOTATION}" "^chr15	"                "chr15"
assert_contains     "${TEST_MANE_ANNOTATION}" "^chr22	"                "chr22"
assert_contains     "${TEST_MANE_ANNOTATION}" "^chr22_KQ759762v2_fix	" "chr22_KQ759762v2_fix"
assert_contains     "${TEST_MANE_ANNOTATION}" "^#"                      "GTF header lines"
assert_not_contains "${TEST_MANE_ANNOTATION}" "^chr1	"                 "chr1 (should be absent)"
# chr22_ML143380v1_fix has no entries in the MANE v1.5 release
assert_not_contains "${TEST_MANE_ANNOTATION}" "^chr22_ML143380v1_fix	" "chr22_ML143380v1_fix (not in MANE v1.5)"

# ── 7. GRC fixes — correct patches only ────────────────────────────────────
section "7. GRC fixes"

for patch in "${GRC_FIX_PATCHES[@]}"; do
    assert_contains "${TEST_GRC_FIXES}" "${patch}" "${patch}"
done
# The file should NOT be a full dump (spot-check an unrelated patch)
assert_not_contains "${TEST_GRC_FIXES}" "HG2291_PATCH" "HG2291_PATCH (unrelated patch, should be absent)"

# ── 8. EBV files — basic sanity ────────────────────────────────────────────
section "8. EBV FASTA & GTF"

assert_contains "${TEST_EBV_FASTA}"       "^>" "FASTA header"
assert_contains "${TEST_EBV_ANNOTATION}"  "NC_007605\|^#" "EBV accession or header"
assert_min_lines "${TEST_EBV_ANNOTATION}" 10

# ── 9. Clinically relevant genes — expected columns present ────────────────
section "9. Clinically relevant genes TSV"

assert_min_lines "${TEST_CLINICALLY_RELEVANT_GENES}" 2  # header + at least one data row

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL=$((PASS + FAIL))
echo "  Results: ${PASS}/${TOTAL} checks passed"
if [ "${FAIL}" -gt 0 ]; then
    echo "  ⚠️  ${FAIL} check(s) failed — review output above."
    exit 1
else
    echo "  🎉 All checks passed!"
    exit 0
fi