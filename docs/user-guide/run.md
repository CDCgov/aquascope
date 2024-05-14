## Run the pipeline

5. Run the pipeline profile
    ```
    nextflow run main.nf -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
    ```
    A. The `-profile test` will run the test parameters and samples. Currently, the test samples are illumina samples and we are intending to provide ion-torrent and nanopore data in our next pipeline version.
    ```
    nextflow run main.nf -profile test,singularity
    ```
    > * Please check with your `HPC infrastructure Team` for custom config files. For all CDC-users, we have a `rosalind` cluster config to run this pipeline and reach out to [`SciComp`] (https://info.biotech.cdc.gov/info/) for additional help.
    > * If you are using `singularity` then the pipeline will auto-detect this and attempt to download the Singularity images directly as opposed to performing a conversion from Docker images. If you are persistently observing issues downloading Singularity images directly due to timeout or network issues then please use the `--singularity_pull_docker_container` parameter to pull and convert the Docker image instead. Alternatively, it is highly recommended to use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to pre-download all of the required containers before running the pipeline and to set the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options to be able to store and re-use the images from a central location for future pipeline runs.
    > * If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

6.  Start running your own analysis!

    > * fasta, bed and gff parameters are defaulted to references in the assets folder of the pipeline. if you want to change the references, please use --fasta, --gff and --gff3 as input parameters

    >* Note: Bed file is used for QUALIMAP-BAMQC, GFF in GFF3 format for FREYJA variant calling 

    ```
    nextflow run main.nf -profile <docker/singularity> --input samplesheet.csv --outdir results
    ```
    >* Note: Docker isn't supported on CDC (Rosalind) infrastructure.

7. If you have a saved copy of freyja curated lineages and barcodes, please use the following parameters in the command line and run the pipeline:
    ```
    nextflow run main.nf -profile <docker/singularity> --input samplesheet.csv --freyja_barcodes <path_to_barcode_file> --freyja_lineages_meta <path_to_lineage_file> --outdir results
    ```