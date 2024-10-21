# Prepare the Samplesheets

## Samplesheet for `QUALITY_ALIGN` or `AQUASCOPE` workflows
	
- Create a samplesheet using the following reference: 
    - `assets/samplesheet_test_illumina.csv`
    - `assets/samplesheet_test_ont.csv`

Notes:
    - Currently, Illumina, Ion-torrent and Oxford Nanopore platforms are supported in this pipeline.
    - Bedfiles can be a local file path or a raw.github url

## Samplesheet for `FREYJA_ONLY` workflow

Option 1. Create a samplesheet using the following reference: 
    - `assets/samplesheet_test_bam.csv`

Option 2. Create samplesheet for primer trimmed bams using the python script `bin/bam_to_samplesheet.py`
  ```
  python bin/bam_to_samplesheet.py \
    --directory <PATH_TO_BAM_FILES> \
    --output <OUTPUT_FILE>"
  ```

# Prepare the config files
Prepare the configuration files

A. `scicomp.config`: CDC specific config to run on SciComp resources.

B. `test.config` is prepared with default parameters; update as needed
