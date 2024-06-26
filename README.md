<p align="center">
  <img src="https://github.com/CDCgov/aquascope/assets/20726305/62d44e22-a870-4a28-9d9d-d21b6e3c4ca0" alt="Aquascope_V2_50">
</p>

<h1 align="center">Aquascope</h1>
<div align="center">
  <a href="https://www.nextflow.io/">
    <img src="https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.04.0-23aa62.svg?labelColor=000000" alt="Nextflow">
  </a>
  <a href="https://docs.conda.io/en/latest/">
    <img src="http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda" alt="run with conda">
  </a>
  <a href="https://www.docker.com/">
    <img src="https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker" alt="run with docker">
  </a>
  <a href="https://sylabs.io/docs/">
    <img src="https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000" alt="run with singularity">
  </a>
</div>

## Introduction
**CDCgov/aquascope** is a bioinformatics best-practice pipeline for early detection of SARS-COV variants of concern, sequenced throughshotgun metagenomic sequencing, from wastewater.

This project is a successor to the [C-WAP pipeline](https://github.com/CFSAN-Biostatistics/C-WAP) and is intended to process SARS-CoV-2 wastewater samples to determine relative variant abundance.  

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. 

## Pipeline summary

1. Read QC: [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
2. Trimming reads: [`Fastp`](https://github.com/OpenGene/fastp)
3. Aligning short reads: [`Minimap2`](https://github.com/lh3/minimap2)
4. Ivar trim aligned reads: [`IVAR Trim`](https://andersen-lab.github.io/ivar/html/manualpage.html)
5. Freyja Variant classification: [`Freyja`](https://github.com/andersen-lab/Freyja)
6. Present QC for raw reads: [`MultiQC`](http://multiqc.info/)

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.04.0`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(please only use [`Conda`](https://conda.io/miniconda.html) as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_

3. Prepare the `assets/samplesheet.csv`. Refer to [prepare-files] (https://cdcgov.github.io/aquascope/).

4. Prepare the configuration files
	A. `nextflow.config` is prepared with default parameters, update as needed
	B. `test.config` is prepared with default parameters, update as needed
	C. `cdc-dev.config` is prepared for **CDC-Users** and it has the **Rosalind** cluster configurations.

5. Run the pipeline profile
    ```
    nextflow run main.nf -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
    ```
    A. The `-profile test` will run the test parameters and samples only for Illumina test data
   
    > * Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment. NOTE: CDC users can only use singularity on SciComp resources.
    > * If you are using `singularity` then the pipeline will auto-detect this and attempt to download the Singularity images directly. If you are persistently observing issues downloading Singularity images directly due to timeout or network issues then please use the `--singularity_pull_docker_container` parameter to pull and convert the Docker image instead. 
    > * If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

## Documentation
For more detailed documentation, please visit our [user-guides](https://cdcgov.github.io/aquascope/).

## Contributions and Support
`Aquascope` was largely developed by [OAMD's](https://www.cdc.gov/amd/index.html) SciComp Team, with inputs from [NWSS](https://www.cdc.gov/nwss/wastewater-surveillance.html) and the DCIPHER Team at Palantir. Detailed contributions can be found in our [user-guides](https://cdcgov.github.io/aquascope/user-guide/contributions/).

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#aquascope` channel](https://nfcore.slack.com/channels/aquascope) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations
An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.
