## Prepare the Samplesheet
Prepare the `assets/samplesheet.csv`
	
A. Create additional sample sheets using the following samplesheet as reference.

B. Currently, Illumina, Ion-torrent and Oxford Nanopore platforms are supported in this pipeline.

C. Bedfiles can be a local file path or a raw.github url

D. `Keywords`: lr - Longreads, bam_file - Only for Ion-torrent platform, platform - sequencing platform.

## Prepare the config files
Prepare the configuration files

A. cdc-dev.config: All CDC-users must use the cdc-dev.config to run the pipeline on `Rosalind` cluster.

B. `test.config` is prepared with default parameters, update as needed
