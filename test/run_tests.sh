outDir="$HOME/projects/tmp/aqua_tests/"
if [[ -d $outDir ]]; then rm -rf $outDir; fi
mkdir -p $outDir

module purge
module --ignore-cache load nextflow/24.10.4
module --ignore-cache load singularity/4.1.4

source /etc/profile

nextflow run main.nf --resume -profile singularity,test_illumina -entry AQUASCOPE --outdir $outDir/ILLUMINA/complete
nextflow run main.nf --resume -profile singularity,test_illumina -entry QUALITY_ALIGN --outdir $outDir/ILLUMINA/quality
nextflow run main.nf --resume -profile singularity,test_bam -entry AQUASCOPE --outdir $outDir/BAM/COMPLETE
nextflow run main.nf --resume -profile singularity,test_iontorrent -entry AQUASCOPE --outdir $outDir/iontorrent
nextflow run main.nf --resume -profile singularity,test_ont -entry AQUASCOPE --outdir $outDir/ONT/COMPLETE
