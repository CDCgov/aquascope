# Output

This document describes the output produced by the pipeline. Most of the plots are taken from the MultiQC report, which summarises results at the end of the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

## [FASTQC](#fastqc)
This folder contains FastQC reports for ILLUMINA data, both pre and post trimming. `Raw_Reads` and `Trimmed_Reads` are the output directories.
- **Output**: Quality metrics for raw and trimmed short-read data.

<details markdown="1">
<summary>Output files</summary>

* `fastqc/`
    * `*_fastqc.html`: FastQC report containing quality metrics.
    * `*_fastqc.zip`: Zip archive containing the FastQC report, tab-delimited data file and plot images.

</details>

## [NANOPLOT](#nanoplot)
This folder contains NanoPlot reports for ONT data, both pre and post trimming. `Raw_Reads` and `Trimmed_Reads` are the output directories.
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

## [FASTP](#fastp)
This folder contains trimmed reads from both short and long reads.
- **Output**: Adapter trimmed reads for both long and short-read data.

<details markdown="3">
<summary>Output files</summary>

* `fastp/`
    * `*_fastp.html`: Fastp report of trimmed reads and post trimming quality metrics.
    * `*_fastp.json`: json file for the above report.
    * `*_fastp.fastq.gz`: a trimmed fastq file for both short and long-reads

</details>

## [Qualimap/BAMQC](#qualimap-bamqc)
This folder contains BAMQC reports for aligned reads. It includes quality metrics and coverage statistics for BAM files.
- **Output**: Quality metrics and coverage statistics reports.

<details markdown="4">
<summary>Output files</summary>

* `Bamqc/`
    * `*qualimapReport.html`: Qualimap - Bamqc report of aligned BAM file.
    * `*raw_data_qualimapReport`: Coverage, gc content, nucleotide content, mapping quality metrics are reported in this folder.
    * `*genome_results.txt`: cumulative report containing all the above metrics.

</details>

## [ALIGNMENT/MINIMAP2](#alignment-minimap2)
This folder contains alignment files generated using Minimap2.
- **Output**: Aligned reads in BAM format.

<details markdown="5">
<summary>Output files</summary>

* `minimap2/`
    * `*.bam`: Aligned bam files

</details>

## [SAMTOOLS](#samtools)
This folder contains BAM file statistics and reference indexing.
- **Output**: Statistics on each BAM file and a reference index.

<details markdown="6">
<summary>Output files</summary>

* `Samtools/`
    * `*.flagstat`: Primary statistics on aligned bam files
    * `*.stats` : General statistics
    * `*.reference.fasta.fai`: Reference index

</details>


## [PRIMERTRIMMING](#AmpliconClip_and_iVar_Trimming)
This folder contains reads with trimmed primers using `samtools ampliconclip` for ONT data and `ivar trim` for Illumina data.
- **Output**: BAM files with primers trimmed.

<details markdown="7">
<summary>Output files</summary>

* `iVarTrim (Illumina)`
    * `*.ivar_trim.bam`: ivar trimmed bam files, the primers used here are SARS-CoV2 based.

* `AmpliconClip (Oxford Nanopore)`
    * `*.ampliconclip.clipallowed.bam`: samtools amplicon clip trimmed bam files.

</details>

## [VariantCalling](#ivar_and_freyja_variant_calling)
This folder contains variant calling and demixing results using Freyja.
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

## [MultiQC](#multiqc)
This folder contains an aggregated report describing quality control results from the pipeline.
- **Output**: MultQC report.

<details markdown="9">
<summary>Output files</summary>

* `multiqc/`
    * `multiqc_report.html`: a standalone HTML file that can be viewed in your web browser.
    * `multiqc_data/`: directory containing parsed statistics from the different tools used in the pipeline.
    * `multiqc_plots/`: directory containing static images from the report in various formats.

</details>

## [Execution Reports](#pipeline-information) 
This folder contains report metrics generated during the workflow execution.
- **Output**: Execution based reports.

<details markdown="10">
<summary>Output files</summary>

* `pipeline_info/`
    * Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
    * Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.tsv`.
    * Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

</details>