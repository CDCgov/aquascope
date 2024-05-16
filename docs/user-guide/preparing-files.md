## Prepare the Samplesheet
Prepare the `assets/samplesheet.csv`
	
    1. Create additional sample sheets using the following samplesheet as reference.

    2. Currently, Illumina, Ion-torrent and Oxford Nanopore platforms are supported in this pipeline.

    3. Bedfiles can be a local file path or a raw.github url

    4. `Keywords`: lr - Longreads, bam_file - Only for Ion-torrent platform, platform - sequencing platform.

## Prepare the config files
Prepare the configuration files

    1. cdc-dev.config: All CDC-users must use the cdc-dev.config to run the pipeline on `Rosalind` cluster.

    2. `test.config` is prepared with default parameters, update as needed
