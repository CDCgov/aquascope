# Test Information
Welcome to the Aquascope Pipeline Tutorial!

## Getting Started
Review the information on the [Getting Started](https://cdcgov.github.io/aquascope/user-guide/getting-started/) for a complete overview of the pipeline. The tutorial below will use test data available as part of the pipeline in the assets folder that runs on any HPC environment and was primarily tested using singularity container. All example code will assume you are running v2.0.0 of the pipeline, using test data available on GitHub.

A. Change launch directory to the CDCgov/aquascope folder after your git clone or nextflow pull the pipeline.

B. *CDC-Users Only* Your NXF_WORK, NXF_CONDA_CACHEDIR, NXF_SINGULARITY_CACHEDIR & NXF_TEMP are set to Scratch folder as soon as you module load Nextflow. To override the defults, please manually set these environemental variables in ~/.bashrc.

C. *CDC-Users Only* Please check with your `HPC infrastructure Team` for custom config files. We have a `rosalind` cluster config to run this pipeline and please reach out to [`SciComp`](https://info.biotech.cdc.gov/info/helpdesk/) for additional help.


## Decide the test to perform
The pipeline includes three different entry points (View [Getting Started](https://github.com/CDCgov/aquascope/blob/feature_docs/docs/user-guide/getting-started.md) for more information) and three different data inputs (Illumina, ONT, BAM). Determine which test meets your needs.

A. Test Illumina Input 
Test [samplesheet](https://github.com/CDCgov/aquascope/blob/dev/assets/samplesheet_test_illumina.csv) is included in the .assets/ directory. The `test_illumina` profile will automatically configure this input.

```
### CDC Internal Users
nextflow run \
main.nf \
-profile test_illumina,singularity,scicomp_rosalind
-entry AQUASCOPE

### All Other Users
nextflow run \
main.nf \
-profile test_illumina,<docker,singularity,nf-core institutional config
-entry AQUASCOPE
```

B. Test ONT Input 
Test [samplesheet](https://github.com/CDCgov/aquascope/blob/dev/assets/samplesheet_test_ont.csv) is included in the .assets/ directory. The `test_ont` profile will automatically configure this input.

```
### CDC Internal Users
nextflow run \
main.nf \
-profile test_ont,singularity,scicomp_rosalind
-entry AQUASCOPE

### All Other Users
nextflow run \
main.nf \
-profile test_ont,<docker,singularity,nf-core institutional config
-entry AQUASCOPE
```

C. Test BAM Input 
Test [samplesheet](https://github.com/CDCgov/aquascope/blob/main/assets/samplesheet_test_bam.csv) is included in the .assets/ directory. The `test_bams` profile will automatically configure this input.

```
### CDC Internal Users
nextflow run \
main.nf \
-profile test_bams,singularity,scicomp_rosalind
-entry AQUASCOPE

### All Other Users
nextflow run \
main.nf \
-profile test_bams,<docker,singularity,nf-core institutional config
-entry AQUASCOPE
```
