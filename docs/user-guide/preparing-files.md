# Prepare the Samplesheets

You will need to create a samplesheet with information about the samples you would like to analyse before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with a header row as shown in the examples below.

## Samplesheet input

```console
--input '[path to samplesheet file]'
```

## Samplesheet for `QUALITY_ALIGN` or `AQUASCOPE` workflows
	
- Create a samplesheet using the following reference: 
    - [Illumina example](../../assets/samplesheet_test_illumina.csv)
    - [ONT example](../../assets/samplesheet_test_ont.csv)

Notes:
    - Currently, Illumina, Ion-torrent and Oxford Nanopore platforms are supported in this pipeline.
    - Bedfiles can be a local file path or a raw.github url

The pipeline will auto-detect whether a sample is single- or paired-end using the information provided in the samplesheet. It auto-detects sequencing platform (Illumina, Ion-torrent and Oxford nanopore) and determines which set of tools have to be run. The samplesheet must have 7 columns, and have to be in the same order as the header shown below.

A samplesheet file consisting of both single- and paired-end Illumina data may look something like the one below. This is for 2 samples.

```console
sample,platform,fastq_1,fastq_2,lr,bam_file,bedfile
SAMPLE1_PE,illumina,https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/illumina/amplicon/sample1_R1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/illumina/amplicon/sample1_R2.fastq.gz,,,https://raw.githubusercontent.com/artic-network/primer-schemes/master/nCoV-2019/V3/nCoV-2019.primer.bed
SAMPLE1_SE,illumina,https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/illumina/amplicon/sample1_R1.fastq.gz,,,,https://raw.githubusercontent.com/artic-network/primer-schemes/master/nCoV-2019/V3/nCoV-2019.primer.bed
```

| Column         | Description                                                                                                                                                                            |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `sample`       | Custom sample name. This entry will be identical for multiple sequencing libraries/runs from the same sample. Spaces in sample names are automatically converted to underscores (`_`). |
| `platform`     | Sequencing platform. This entry will determine the type of sequencing used. It is an important entry as the decision to run a set of tools is determined by this entry.             |
| `fastq_1`      | Full path to FastQ file for Illumina short reads 1. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz".                                                             |
| `fastq_2`      | Full path to FastQ file for Illumina short reads 2. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz".                                                             |
| `lr`           | Full path to FastQ file for ONT long reads. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz". fast5 files are not expected or accepted                              |
| `bam_file`     | Full path to BAM file for Ion-torrent short reads. File has to .bam strictly| 
| `bedfile`     |  Full path to local bed file or rawgithub url. File has to .tsv              | 


## Samplesheet for `FREYJA_ONLY` workflow

```console
sample,bam_file
Sample1,test/Sample1.bam
Sample2,test/Sample2.bam
```

| Column         | Description                                                                                                                                                                            |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `sample`       | Custom sample name. This entry will be identical for multiple sequencing libraries/runs from the same sample. Spaces in sample names are automatically converted to underscores (`_`). |
| `bam_file`     | Full path to BAM file for Ion-torrent short reads. File has to .bam strictly| 


Option 1. Create a samplesheet using the following reference: 
    - [BAM example](../../assets/samplesheet_test_bam.csv)

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
