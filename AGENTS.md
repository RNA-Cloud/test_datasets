# AGENTS.md

## Repository purpose
This repository is a shell-based fixture builder for small branch-scoped genomics reference datasets used in automated testing. It is not an application service. The main artefacts are the generated files under `data/`, and the source of truth for behaviour is the shell configuration and validation logic.

## Current repository model
The repository currently maintains two dataset bundles:

- `rna_cloud`: outputs written directly under `data/`
- `legacy_1`: outputs written under `data/legacy_1/`

Treat each bundle as an independently versioned downstream contract with its own config, prep script, and validation script.

## Key files
- `config/rna_cloud.sh`: canonical RNA-Cloud source URLs, raw cache paths, output paths, and retained identifiers.
- `config/legacy_1.sh`: canonical Legacy 1 source URLs, raw cache paths, output paths, and retained identifiers.
- `prep_rna_cloud_test_data.sh`: destructive rebuild of the RNA-Cloud bundle. It removes and recreates `data/`.
- `validate_rna_cloud_test_data.sh`: executable RNA-Cloud specification and primary regression check for that bundle.
- `prep_legacy_1_test_data.sh`: destructive rebuild of the Legacy 1 bundle. It removes and recreates `data/legacy_1/`.
- `validate_legacy_1_test_data.sh`: executable Legacy 1 specification and primary regression check for that bundle.
- `Makefile`: operator entry points (`make help`, `make prep_data`, `make validate_data`, `make all`).
- `README.md`: high-level usage, layout, and downstream RNA-Cloud `sources.json` example.
- `docs/SPECIFICATION.md`: expanded dataset contract for both bundles.

## Working rules for agents
- Treat `config/rna_cloud.sh` plus `validate_rna_cloud_test_data.sh` as the authoritative RNA-Cloud contract.
- Treat `config/legacy_1.sh` plus `validate_legacy_1_test_data.sh` as the authoritative Legacy 1 contract.
- Prefer changing scripts and configuration over manually editing generated files in `data/`.
- Assume `data/` is generated output. If generation logic, source URLs, or retained identifiers change, regenerate and revalidate.
- Do not place hand-maintained files under `data/`. `prep_rna_cloud_test_data.sh` removes `data/`, and `prep_legacy_1_test_data.sh` removes `data/legacy_1/`.
- `raw/` and `raw/legacy_1/` are caches of upstream artefacts when the prep scripts define raw targets. Reuse them when possible.
- Some RNA-Cloud artefacts are downloaded directly to final outputs rather than cached first. At present this applies to EBV FASTA, EBV GTF, and clinically relevant genes.
- Keep the repo branch-scoped. Prepared datasets are intended to live on dedicated workflow branches, not on `main`.

## Expected workflow
1. Read the relevant config file in `config/` before changing a bundle.
2. Edit the matching prep and validation scripts together when the bundle contract changes.
3. Run `make prep_data` when generation logic, sources, or retained identifiers change.
4. Run `make validate_data` after any relevant change.
5. Update `README.md` and `docs/SPECIFICATION.md` whenever the externally visible contract changes.

## Environment assumptions
- Required tools: `bash`, `seqkit`, `wget`, `gzip`, `gunzip`, `grep`, `awk`, `mkdir`.
- Network access is required for `make prep_data` when a required cached input is missing or when a direct-to-output download is absent.
- Validation is local-only and should pass without network access if the expected outputs already exist.

## Dataset contract highlights
- RNA-Cloud GRCh38 FASTA and GTF retain only the RefSeq accessions listed in `config/rna_cloud.sh`.
- RNA-Cloud MANE retains only the chromosome names listed in `MANE_CHROMS`.
- RNA-Cloud GRC fixes retain only the patch names listed in `GRC_FIX_PATCHES`.
- RNA-Cloud CEN/PAR mask regions retain the header plus `chr22` rows only.
- RNA-Cloud EBV FASTA, EBV GTF, and clinically relevant genes are downloaded as-is.
- Legacy 1 FASTA and GTF retain only the chromosome and alt/random contig identifiers listed in `config/legacy_1.sh`.

## Change guidance
- If you update an upstream URL, also check cache paths, filenames, compression expectations, and validation assertions.
- If you add or remove retained contigs, chromosomes, or patch names, update both generation and validation logic in the same change.
- If you add a new published output, document it in `README.md` and `docs/SPECIFICATION.md` and add validation coverage.
- If a downstream workflow changes only one bundle, keep the other bundle’s contract untouched unless an intentional cross-bundle update is required.
