# aquascope: Output

## Introduction

This document describes the output produced by the pipeline. Most of the plots are taken from the MultiQC report, which summarises results at the end of the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

## [FASTQC](#fastqc)
This folder contains FastQC reports for ILLUMINA data, both pre and post trimming. `Raw_Reads` and `Trimmed_Reads` are the output directories.
- **Input**: Raw and Trimmed short-read data.
- **Output**: Quality metrics for raw and trimmed short-read data.

<details markdown="1">
<summary>Output files</summary>

* `fastqc/`
    * `*_fastqc.html`: FastQC report containing quality metrics.
    * `*_fastqc.zip`: Zip archive containing the FastQC report, tab-delimited data file and plot images.

</details>

[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) gives general quality metrics about your sequenced reads. It provides information about the quality score distribution across your reads, per base sequence content (%A/T/G/C), adapter contamination and overrepresented sequences. For further reading and documentation see the [FastQC help pages](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/).

## [NANOPLOT](#nanoplot)
This folder contains NanoPlot reports for ONT data, both pre and post trimming. `Raw_Reads` and `Trimmed_Reads` are the output directories.
- **Input**: Raw and Trimmed long-read data.
- **Output**: Quality metrics for long-read data.

<details markdown="2">
<summary>Output files</summary>

* `nanoplot/`
    * `*_QualityScatterPlot_dot.html &.png`: Nanoplot report containing quality metrics.
    * `*WeightedHistogramReadlength.html & .png`: Weighted histogram on read lengths.
    * `*NonWeightedHistogramReadlength.html & .png`: Non-Weighted histogram on read lengths.
    * `NanoPlot-report.html`: Cumulative report of all the above metrics.
    * `NanoStats.txt`: Cumulative statistics of Read lengths, read quality, basepair quality, N50 metrics.

</details>

[NanoPlot](https://github.com/wdecoster/NanoPlot) gives general quality metrics about your sequenced reads. its a Plotting tool for long read sequencing data and alignments.


## [FASTP](#fastp)
This folder contains trimmed reads from both short and long reads.
- **Input**: Trimmed reads from short and long-reads.
- **Output**: Adapter trimmed reads for both long and short-read data.

<details markdown="3">
<summary>Output files</summary>

* `fastp/`
    * `*_fastp.html`: Fastp report of trimmed reads and post trimming quality metrics.
    * `*_fastp.json`: json file for the above report.
    * `*_fastp.fastq.gz`: a trimmed fastq file for both short and long-reads

</details>

[Fastp](https://github.com/OpenGene/fastp) A tool designed to provide fast all-in-one preprocessing for FastQ files. This tool is developed in C++ with multithreading supported to afford high performance.


## [Qualimap/BAMQC](#qualimap-bamqc)
This folder contains BAMQC reports for aligned reads. It includes quality metrics and coverage statistics for BAM files.
- **Input**: BAM files from alignment step.
- **Output**: Quality metrics and coverage statistics reports.

<details markdown="4">
<summary>Output files</summary>

* `Bamqc/`
    * `*qualimapReport.html`: Qualimap - Bamqc report of aligned BAM file.
    * `*raw_data_qualimapReport`: Coverage, gc content, nucleotide content, mapping quality metrics are reported in this folder.
    * `*genome_results.txt`: cumulative report containing all the above metrics.

</details>

[Qualimap](http://qualimap.conesalab.org/) Qualimap examines sequencing alignment data in SAM/BAM files according to the features of the mapped reads and provides an overall view of the data that helps to the detect biases in the sequencing and/or mapping of the data and eases decision-making for further analysis.


## [ALIGNMENT/MINIMAP2](#alignment-minimap2)
This folder contains alignment files generated using Minimap2.
- **Input**: Trimmed reads from FASTP step.
- **Output**: Aligned reads in BAM format.

<details markdown="5">
<summary>Output files</summary>

* `minimap2/`
    * `*.bam`: Aligned bam files

</details>

[Minimap2](https://github.com/lh3/minimap2) Minimap2 is a versatile sequence alignment program that aligns DNA or mRNA sequences against a large reference database. Typical use cases include: (1) mapping PacBio or Oxford Nanopore genomic reads to the human genome; (2) finding overlaps between long reads with error rate up to ~15%; (3) splice-aware alignment of PacBio Iso-Seq or Nanopore cDNA or Direct RNA reads against a reference genome; (4) aligning Illumina single- or paired-end reads; (5) assembly-to-assembly alignment; (6) full-genome alignment between two closely related species with divergence below ~15%.

## [SAMTOOLS](#samtools)
This folder contains BAM file statistics and reference indexing.
- **Input**: BAM file from the ALIGNMENT step.
- **Output**: Statistics on each BAM file and a reference index.

<details markdown="6">
<summary>Output files</summary>

* `Samtools/`
    * `*.flagstat`: Primary statistics on aligned bam files
    * `*.stats` : General statistics
    * `*.reference.fasta.fai`: Reference index

</details>

[Samtools](http://www.htslib.org/) Samtools is a suite of programs for interacting with high-throughput sequencing data.


## [PRIMERTRIMMING](#AmpliconClip and iVar Trimming)
This folder contains reads with trimmed primers using `samtools ampliconclip` for ONT data and `ivar trim` for Illumina data.
- **Input**: Aligned BAM files.
- **Output**: BAM files with primers trimmed.

<details markdown="7">
<summary>Output files</summary>

* `iVarTrim (Illumina)`
    * `*.ivar_trim.bam`: ivar trimmed bam files, the primers used here are SARS-CoV2 based.

* `AmpliconClip (Oxford Nanopore)`
    * `*.ampliconclip.clipallowed.bam`: samtools amplicon clip trimmed bam files.

</details>

[ivarTrim](https://andersen-lab.github.io/ivar/html/manualpage.html) iVar uses primer positions supplied in a BED file to soft clip primer sequences from an aligned and sorted BAM file. Following this, the reads are trimmed based on a quality threshold(Default: 20)

[AmpliconClip](http://www.htslib.org/doc/samtools-ampliconclip.html) Clips the ends of read alignments if they intersect with regions defined in a BED file. While this tool was originally written for clipping read alignment positions which correspond to amplicon primer locations it can also be used in other contexts. 

## [VariantCalling](#ivar Variant calling and Freyja Variant calling)
This folder contains variant calling and demixing results using Freyja.
- **Input**: Primer trimmed BAM files.
- **Output**: Variant calls and demixed sequences.

<details markdown="8">
<summary>Output files</summary>

* `iVarTrim/VarCalls`
    * `*.tsv`: ivar trimmed variant calls
    * `*.mpileup` : mpileup files from ivar trimmed BAM files only.

* `Freyja/VarCalls`
    * `*.depth.tsv` : Basepair depth at each position.
    * `*.variants.tsv` : Variant calls from both ivar and ampliconclip trimmed BAM files

* `Freyja/Demix`
    * `*.tsv` : Lineage abundances of Sars-cov-2 

</details>

[ivarVariantCalling](https://andersen-lab.github.io/ivar/html/manualpage.html) iVar uses the output of the samtools mpileup command to call variants - single nucleotide variants(SNVs) and indels.

[Freyja](https://github.com/andersen-lab/Freyja) Perform variant calling using samtools and iVar on a BAMFILE and generates relative lineage abundances from VARIANTS and DEPTHS.

## [MultiQC](#multiqc) - Aggregate report describing results and QC from the whole pipeline

<details markdown="9">
<summary>Output files</summary>

* `multiqc/`
    * `multiqc_report.html`: a standalone HTML file that can be viewed in your web browser.
    * `multiqc_data/`: directory containing parsed statistics from the different tools used in the pipeline.
    * `multiqc_plots/`: directory containing static images from the report in various formats.

</details>

[MultiQC](http://multiqc.info) is a visualization tool that generates a single HTML report summarising all samples in your project. Most of the pipeline QC results are visualised in the report and further statistics are available in the report data directory.

Results generated by MultiQC collate pipeline QC from supported tools e.g. FastQC. The pipeline has special steps which also allow the software versions to be reported in the MultiQC output for future traceability. For more information about how to use MultiQC reports, see <http://multiqc.info>.

## [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution


<details markdown="10">
<summary>Output files</summary>

* `pipeline_info/`
    * Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
    * Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.tsv`.
    * Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.