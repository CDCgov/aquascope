# Pipeline Tutorial
Welcome to the Aquascope Pipeline Tutorial!

## Getting Started
Review the information on the [Getting Started](https://github.com/CDCgov/aquascope/blob/feature_docs/docs/user-guide/getting-started.md) for a complete overview of the pipeline. The tutorial below will use test data available as part of the pipeline in the assets folder that runs on any HPC environment and was primarily tested using singularity container. All example code will assume you are running v2.0.0 of the pipeline, using test data available on GitHub.

- Change launch directory to the CDCgov/aquascope folder after your git clone or nextflow pull the pipeline.

- *CDC-Users Only* Your NXF_WORK, NXF_CONDA_CACHEDIR, NXF_SINGULARITY_CACHEDIR & NXF_TEMP are set to Scratch folder as soon as you module load Nextflow. To override the defults, please manually set these environemental variables in ~/.bashrc.

- *CDC-Users Only* Please check with your `HPC infrastructure Team` for custom config files. We have a `rosalind` cluster config to run this pipeline and please reach out to [`SciComp`] (https://info.biotech.cdc.gov/info/) for additional help.


## Submit the test data
Two test samplesheets are available, depending on the input data type: [ONT] (https://github.com/CDCgov/aquascope/blob/dev/assets/samplesheet_test_ont.csv) and [ILLUMINA] (https://github.com/CDCgov/aquascope/blob/dev/assets/samplesheet_test_illumina.csv)

A. Submit Pipeline [Internal-CDC-Users]
```
# ONT data
nextflow run main.nf \
-profile test_ont,singularity,rosalind

nextflow run main.nf \
-profile test_illumina,singularity,rosalind
```

B. Submit Pipeline [External-Users]
```
nextflow run main.nf \
-profile test_ont,singularity,rosalind
```
