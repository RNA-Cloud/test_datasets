# Test Datasets
Test data to be used for automated testing with the nf-core pipelines, nextflow pipelines or other tools/workflows.

> [!WARNING]
> **Do not merge your test data to `main`! Each tool/workflow has a dedicated branch**

# Sources

| Variable                  | URL                                                                                                                                                                                                                                                                                                                                                              |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FASTA_URL                 | [https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.fna.gz](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.fna.gz)                                                                                               |
| ANNOTATION_URL            | [https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz)                                                                                               |
| ASSEMBLY_REPORT           | [https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_assembly_report.txt](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_assembly_report.txt)                                                                                     |
| CEN_PAR_MASK_REGIONS      | [https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GRCh38_major_release_seqs_for_alignment_pipelines/unmasked_cognates_of_masked_CEN_PAR.txt](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GRCh38_major_release_seqs_for_alignment_pipelines/unmasked_cognates_of_masked_CEN_PAR.txt) |
| EBV_FASTA_URL             | [https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/402/265/GCF_002402265.1_ASM240226v1/GCF_002402265.1_ASM240226v1_genomic.fna.gz](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/402/265/GCF_002402265.1_ASM240226v1/GCF_002402265.1_ASM240226v1_genomic.fna.gz)                                                                                               |
| EBV_ANNOTATION_URL        | [https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/402/265/GCF_002402265.1_ASM240226v1/GCF_002402265.1_ASM240226v1_genomic.gtf.gz](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/402/265/GCF_002402265.1_ASM240226v1/GCF_002402265.1_ASM240226v1_genomic.gtf.gz)                                                                                               |
| MANE_ANNOTATION_URL       | [https://ftp.ncbi.nlm.nih.gov/refseq/MANE/MANE_human/release_1.5/MANE.GRCh38.v1.5.refseq_genomic.gtf.gz](https://ftp.ncbi.nlm.nih.gov/refseq/MANE/MANE_human/release_1.5/MANE.GRCh38.v1.5.refseq_genomic.gtf.gz)                                                                                                                                                 |
| GRC_FIXES                 | [https://github.com/RNA-Cloud/grc_fixes_monitoring/releases/download/0.0.8/grc_fixes.tsv](https://github.com/RNA-Cloud/grc_fixes_monitoring/releases/download/0.0.8/grc_fixes.tsv)                                                                                                                                                                               |
| CLINICALLY_RELEVANT_GENES | [https://github.com/frontier-genomics/clinically_relevant_genes/releases/download/1.0.2/results.tsv](https://github.com/frontier-genomics/clinically_relevant_genes/releases/download/1.0.2/results.tsv)                                                                                                                                                         |
# Scripts to prepare test data

## Pre-requisites
- seqkit v2.10.0
- wget
- gzip / gunzip
- grep
- awk
- mkdir
- Requires internet access

## Run

**Generate test data**
```bash
./prep_test_data.sh
```

**Validate test data**
```bash
./validate_test_data.sh
```

# Usage
The configuration below can be directly used by the RNA Cloud genome reference pipeline

`sources.json`
```json
{
    "genome": {
        "provider": "NCBI Refseq",
        "fasta_url": "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.fna.gz",
        "annotation_url": "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz",
        "assembly_report": "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_assembly_report.txt",
        "assembly_report_comment_lines": 63,
        "cen_par_mask_regions": "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GRCh38_major_release_seqs_for_alignment_pipelines/unmasked_cognates_of_masked_CEN_PAR.txt",
        "ebv_fasta_url": "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/402/265/GCF_002402265.1_ASM240226v1/GCF_002402265.1_ASM240226v1_genomic.fna.gz",
        "ebv_annotation_url": "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/402/265/GCF_002402265.1_ASM240226v1/GCF_002402265.1_ASM240226v1_genomic.gtf.gz",
        "refseq_mane_annotation_url": "https://ftp.ncbi.nlm.nih.gov/refseq/MANE/MANE_human/release_1.5/MANE.GRCh38.v1.5.refseq_genomic.gtf.gz"
    },
    "reference": {
        "grc_fixes": "https://github.com/kidsneuro-lab/grc_fixes_monitoring/releases/download/0.0.1/grc_fixes.tsv",
        "clinically_relevant_genes": "https://github.com/frontier-genomics/clinically_relevant_genes/releases/download/1.0.2/results.tsv"
    },
    "rRNA": {
        "NC_000021": "reference/rRNA/NC_000021.9_45S.gtf",
        "NT_167214": "reference/rRNA/NT_167214.1.gtf",
        "NT_187388": "reference/rRNA/NT_187388.1.gtf"
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