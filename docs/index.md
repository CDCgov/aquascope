<p align="center">
  <img src="https://github.com/CDCgov/aquascope/assets/20726305/62d44e22-a870-4a28-9d9d-d21b6e3c4ca0" alt="Aquascope_V2_50">
</p>

This project is a successor to the [C-WAP pipeline](https://github.com/CFSAN-Biostatistics/C-WAP) and is intended to process SARS-CoV-2 wastewater samples to determine relative variant abundance.  

**Aquascope** is a bioinformatics best-practice analysis pipeline for Pipeline is for early detection of SARS-CoV-2 variants of concern via Targeted-amplicon metagenomic sequencing of wastewater. It is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!
