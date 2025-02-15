# Aquascope

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.04.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

## This project is a successor to the [C-WAP pipeline](https://github.com/CFSAN-Biostatistics/C-WAP) and is intended to process SARS-CoV-2 wastewater samples to determine relative variant abundance.  

⚠️Warning⚠️ 

	The results generated by this pipeline are not CLIA certified and should not be considered diagnostic.

## Introduction
**CDCgov/aquascope** is a bioinformatics best-practice pipeline for early detection of SARS-COV variants of concern, sequenced throughshotgun metagenomic sequencing, from wastewater.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. 

## Pipeline summary

1. Read QC: [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
2. Trimming reads: [`Fastp`](https://github.com/OpenGene/fastp)
3. Aligning short reads: [`Minimap2`](https://github.com/lh3/minimap2)
4. Freyja Variant classification: [`Freyja`](https://github.com/andersen-lab/Freyja)
5. Present QC for raw reads: [`MultiQC`](http://multiqc.info/)

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.04.0`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(please only use [`Conda`](https://conda.io/miniconda.html) as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_

3. Prepare the `assets/samplesheet.csv`
	
	- Use the `assets/test_highcoverage_samplesheet.csv` as an example
	
	- Create custom sample sheets using the `fastq_dir_to_samplesheet.py` script
		
		```
		Usage: 
			fastq_dir_to_samplesheet.py \
			/absolute/path/to/fastq/dir \
   			-st <forward/reverse/unstranded> \
   			samplesheetName.csv 
   		```

		i. FASTQ files must be paired end, following `_R1`, `_R2` naming convention.

   		ii. Strandedness must be known or "unstranded". NOTE: DNASeq is by default `unstranded`, while RNASeq is usually `stranded`

4. Prepare the configuration files
	A. `nextflow.config` is prepared with default parameters, update as needed
	B. `test.config` is prepared with default parameters, update as needed

5. Run the pipeline profile
    ```
    nextflow run \
      main.nf \
      -profile <docker/singularity/podman/shifter/charliecloud/conda/institute> \
		  -entry <QUALITY_ALIGN, FREYJA_ONLY, AQUASCOPE>
    ```
   A. The `-profile test` will run the test parameters and samples only for test data
       - test_illumina: Runs Illumina data
       - test_ont: Runs ONT data
       - test_bams: Runs BAM data
   B. Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment. NOTE: CDC users can only use singularity on SciComp resources.
   C. If you are using `singularity` then the pipeline will auto-detect this and attempt to download the Singularity images directly. If you are persistently observing issues downloading Singularity images directly due to timeout or network issues then please use the `--singularity_pull_docker_container` parameter to pull and convert the Docker image instead.
   D. If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

## Documentation
For more detailed documentation, please visit our [user-guides](https://cdcgov.github.io/aquascope/).

## Contributions and Support
`Aquascope` was largely developed by [OAMD's](https://www.cdc.gov/amd/index.html) SciComp Team, with inputs from [NWSS](https://www.cdc.gov/nwss/wastewater-surveillance.html) and the DCIPHER Team at Palantir. Detailed contributions can be found in our [user-guides](https://cdcgov.github.io/aquascope/user-guide/contributions/).

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations
An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.
