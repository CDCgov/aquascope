## Prepare the Samplesheet
Prepare the `assets/samplesheet.csv`
	
A. Create additional sample sheets using the following samplesheet as reference.

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


B. Currently, Illumina, Ion-torrent and Oxford Nanopore platforms are supported in this pipeline.

D. `Keywords`: lr - Longreads, bam_file - Only for Ion-torrent platform, platform - sequencing platform.

## Prepare the config files
Prepare the configuration files

A. cdc-dev.config: All CDC-users must use the cdc-dev.config to run the pipeline on `Rosalind` cluster.

B. `test.config` is prepared with default parameters, update as needed
