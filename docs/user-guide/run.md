# Run the pipeline

## Input Requirements
To run the pipeline, the following inputs may be given at run-time:
- profile (required)
- entry (required)
- input (required)
- outdir (optional)
- references file (optional)
- Freyja-specific files (optional)

```
    nextflow run main.nf \
    -profile <docker/singularity/podman/shifter/charliecloud/conda/institute/test> \
	-entry <QUALITY_ALIGN, FREYJA_ONLY, AQUASCOPE> \
    --input <path/to/samplesheet> \
    --outdir <path/to/out/dir> \
    --fasta </path/to/fasta/> \
    --freyja_barcodes <path_to_barcode_file> \
    --freyja_lineages_meta <path_to_lineage_file> \

```

### Profile (Required)
Select from any of the profiles:
- docker
- singularity
- podman
- shifter
- charliecloud
- conda
- instutitute_specific_profiles

Example:

```
    nextflow run main \
    -profile docker,scicomp_rosalind \
    -entry AQUASCOPE \
    --input <path/to/samplesheet> \
    --outdir <path/to/out/dir>
```

### Entry (Required)
Three entry points are available within Aquascope

- QUALITY_ALIGN: Runs pipeline beginning from quality control through alignment

- FREYJA_ONLY: Runs the pipeline beginning with BAM files through variant calling

- AQUASCOPE: Runs both QUALITY_ALIGN followed by FREYJA_ONLY

```
    nextflow run main.nf \
    -profile <docker/singularity/podman/shifter/charliecloud/conda/institute> \
	-entry <QUALITY_ALIGN, FREYJA_ONLY, AQUASCOPE> \
    --input <path/to/samplesheet> \
    --outdir <path/to/out/dir> \
    --fasta </path/to/fasta/> \
    --freyja_barcodes <path_to_barcode_file> \
    --freyja_lineages_meta <path_to_lineage_file> \

```

### Samplesheet (Required)
Refer to the `Preparing Files` documentaiton for specific samplesheet-related instructions.

Example:

```
    nextflow run main.nf \
    -profile <docker/singularity/podman/shifter/charliecloud/conda/institute> \
	-entry <QUALITY_ALIGN, FREYJA_ONLY, AQUASCOPE> \
    --input samplesheet.csv \
    --outdir <path/to/out/dir>
```

### References (Optional)
Fasta, BED and GFF parameters are defaulted to references in the assets folder of the pipeline. To change, the `--fasta`, `--gff` and `--gff3` are available as input parameters.
    
- NOTES:

    - Docker isn't supported on CDC (Rosalind) infrastructure.

    - BED file is used for QUALIMAP-BAMQC, GFF in GFF3 format for FREYJA variant calling 

Example: 
```
    nextflow run main.nf \
    -profile <docker/singularity/podman/shifter/charliecloud/conda/institute> \
	-entry <QUALITY_ALIGN, FREYJA_ONLY, AQUASCOPE> \
    --input <path/to/samplesheet> \
    --outdir <path/to/out/dir> \
    --fasta reference.fasta
```

### Freyja Curated Lineages / Barcodes
Users can supply saved freyja-curated lineages and barcodes:

```
    nextflow run main.nf \
    -profile <docker/singularity/podman/shifter/charliecloud/conda/institute> \
	-entry <QUALITY_ALIGN, FREYJA_ONLY, AQUASCOPE> \
    --input <path/to/samplesheet> \
    --outdir <path/to/out/dir> \
    --freyja_barcodes <path_to_barcode_file> \
    --freyja_lineages_meta <path_to_lineage_file>
```