# AGENTS.md

## Repository purpose
This repository is a shell-based fixture builder for small reference datasets used in automated testing of RNA-Cloud, nf-core, and related genomics workflows. It is not an application service: the main artefacts are the prepared files in `data/`, and the main executable logic lives in shell scripts.

## Key files
- `config.sh`: canonical source URLs, local paths, and the sequence / patch filters that define the dataset contract.
- `prep_test_data.sh`: destructive rebuild of `data/` from the configured sources.
- `validate_test_data.sh`: executable specification for the prepared outputs; use this as the primary regression check.
- `Makefile`: operator entry points (`make prep_data`, `make validate_data`, `make all`).
- `README.md`: high-level usage and downstream `sources.json` example.

## Working rules for agents
- Treat `config.sh` and `validate_test_data.sh` as the authoritative behaviour definition.
- Prefer changing scripts and configuration over manually editing generated files in `data/`.
- Assume `data/` is generated output. If you change filtering logic or source locations, regenerate and revalidate.
- `prep_test_data.sh` removes and recreates `data/` on every run. Do not place hand-maintained files there.
- `raw/` is a cache of downloaded upstream artefacts. Reuse it when possible; downloading requires network access.
- Keep the repo branch-scoped. The README explicitly warns not to merge test data to `main`; each workflow should use its own dedicated branch.

## Expected workflow
1. Read `config.sh` to understand the retained chromosomes, patch scaffolds, and URLs.
2. Edit `prep_test_data.sh` or `validate_test_data.sh` if the dataset contract changes.
3. Run `make prep_data` when generation logic or sources change.
4. Run `make validate_data` after any relevant change.
5. Update `README.md` and `docs/SPECIFICATION.md` if the external contract changes.

## Environment assumptions
- Required tools: `bash`, `seqkit`, `wget`, `gzip` / `gunzip`, `grep`, `awk`, `mkdir`.
- Network access is required for `make prep_data` when the raw cache is incomplete.
- Validation is local-only and should pass without network access if the expected files already exist.

## Dataset contract highlights
- Main GRCh38 outputs retain only the accessions listed in `GRCH38_SEQ_IDS`.
- MANE output retains only the chromosomes listed in `MANE_CHROMS`.
- GRC fixes retain only the patch names listed in `GRC_FIX_PATCHES`.
- EBV FASTA and GTF are downloaded as-is, not subsetted.
- Clinically relevant genes are downloaded as-is, with validation limited to basic presence and non-emptiness.

## Change guidance
- If you update an upstream URL, also check whether filenames, headers, or validation expectations need adjustment.
- If you add or remove retained contigs or patches, update both generation and validation logic in the same change.
- If a downstream workflow depends on a new file, document it in `README.md` and `docs/SPECIFICATION.md`.
