# Run the pipeline

## Input Requirements
To run the pipeline, the following inputs may be given at run-time:
- profile (required)
- samplesheet (fastq for Aquascope and Bams for Freyja_standalone workflows) (required)
- references file (optional)
- Freyja-specific files (optional)

## Profile (Required)
Select from any of the profiles:
- docker
- singularity
- podman
- shifter
- charliecloud
- conda
- instutitute_specific_profiles

```
    nextflow run main.nf \
    -profile <docker/singularity/podman/shifter/charliecloud/conda/institute> \
    --input samplesheet.csv \
    --outdir results
```

These profiles can be combined together

```
    nextflow run main \
    -profile docker,rosalind_uge \
    --input samplesheet.csv \
    --outdir results
```

## Samplesheet (Required)
Refer to the `Preparing Files` documentaiton for specific samplesheet-related instructions.

## References (Optional)
Fasta, bed and gff parameters are defaulted to references in the assets folder of the pipeline. To change, the `--fasta`, `--gff` and `--gff3` are available as input parameters.
    
- Bed file is used for QUALIMAP-BAMQC, GFF in GFF3 format for FREYJA variant calling 

- Docker isn't supported on CDC (Rosalind) infrastructure.

```
    nextflow run main.nf \
    -profile <docker/singularity> \
    --input samplesheet.csv \
    --outdir results \
    --fasta /path/to/fasta/
```

## Freyja Curated Lineages / Barcodes
Users can supply saved freyja-curated lineages and barcodes:

```
nextflow run main.nf \
    -profile <docker/singularity> \
    --input samplesheet.csv \
    --freyja_barcodes <path_to_barcode_file> \
    --freyja_lineages_meta <path_to_lineage_file> \
    --outdir results
```

## Running Freyja_standalone pipeline
Refer to `Preparing Files` documentation to how to create bam_samplesheet.csv file

```
nextflow run main.nf \
    -profile <docker/singularity> \
    --workflow freyja_standalone \ <default is aquascope, if not specified>
    --input bam_samplesheet.csv \
    --freyja_barcodes <path_to_barcode_file> \
    --freyja_lineages_meta <path_to_lineage_file> \
    --outdir freyj_standalone_results
```