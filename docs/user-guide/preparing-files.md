## Currently, there are 2 workflows - Aquascope for end-to-end analysis and Freyja_Standalone (for only abundance estimations)

When to use which:

- Use "--workflow aquascope" if you are have fastq files and would like to perform END-TO-END analysis

- Use "--workflow freyja_standalone" if you already have a "aligned and trimmed BAM" files from Illumina, Nanopore and Genexus platforms and want to perform "abundance estimations with freyja only"


## Prepare the Samplesheet
Prepare the `assets/samplesheet.csv`
	
A. Create additional sample sheets using the following samplesheet as reference.

B. Currently, Illumina, Ion-torrent and Oxford Nanopore platforms are supported in this pipeline.

C. Bedfiles can be a local file path or a raw.github url

D. `Keywords`: lr - Longreads, bam_file - Only for Ion-torrent platform, platform - sequencing platform, freyja, workflows, aquascope

## Prepare the Samplesheet for Freyja_Standalone workflow

A. Create samplesheet `bam_samplesheet.csv` for Primer trimmed bams using the python script `bam_to_samplesheet.py` in the "bin/" folder

B. Run the following command to create this samplesheet

```
python bam_to_samplesheet.py --directory <PATH_TO_BAM_FILES> --output <OUTPUT_FILE>"

```

## Prepare the config files
Prepare the configuration files

A. cdc-dev.config: All CDC-users must use the cdc-dev.config to run the pipeline on `Rosalind` cluster.

B. `test.config` is prepared with default parameters, update as needed
