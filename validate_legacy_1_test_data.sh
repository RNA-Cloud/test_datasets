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
source "${SCRIPT_DIR}/config/legacy_1.sh"

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

assert_equals() {
    local actual="$1"
    local expected="$2"
    local label="$3"
    if [ "${actual}" = "${expected}" ]; then
        pass "${label}: ${actual}"
    else
        fail "${label}: expected '${expected}', got '${actual}'"
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

echo "🧪 Legacy 1 test data verification"
echo "   Config sourced from: ${SCRIPT_DIR}/config/legacy_1.sh"

# ── 1. File existence & integrity ──────────────────────────────────────────
section "1. File existence & integrity"

for var in \
    TEST_FASTA TEST_FASTA_INDEX TEST_ANNOTATION; do
    file="${!var}"
    assert_file_exists   "${file}"
    assert_file_nonempty "${file}"
    [[ "${file}" == *.gz ]] && assert_gz_valid "${file}"
done

# ── 2. Legacy 1 FASTA — correct sequences retained ─────────────────────────
section "2. Legacy 1 test FASTA"

for seq_id in "${GRCH38_SEQ_IDS[@]}"; do
    assert_contains "${TEST_FASTA}" "^>${seq_id}" "${seq_id}"
done

# ── 3. Legacy 1 FASTA index — correct entries retained ─────────────────────
section "3. Legacy 1 test FASTA index"

assert_min_lines "${TEST_FASTA_INDEX}" "${#GRCH38_SEQ_IDS[@]}"

index_lines=$(awk 'END { print NR }' "${TEST_FASTA_INDEX}")
assert_equals "${index_lines}" "${#GRCH38_SEQ_IDS[@]}" "FASTA index entry count"

for seq_id in "${GRCH38_SEQ_IDS[@]}"; do
    assert_contains "${TEST_FASTA_INDEX}" "^${seq_id}	" "${seq_id}"
done

# ── 4. Legacy 1 GTF — correct chromosomes, header preserved ────────────────
section "4. Legacy 1 test GTF"

assert_contains     "${TEST_ANNOTATION}" "^#" "GTF header lines"
assert_contains     "${TEST_ANNOTATION}" "^chr1	" "chr1 (chr1, should be present)"
assert_contains     "${TEST_ANNOTATION}" "^chr15	" "chr15 (chr15, should be present)"
assert_contains     "${TEST_ANNOTATION}" "^chr21	" "chr21 (chr21, should be present)"
assert_contains     "${TEST_ANNOTATION}" "^chr22	" "chr22 (chr22, should be present)"

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
