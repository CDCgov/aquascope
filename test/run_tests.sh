outDir="$HOME/projects/tmp/aqua/"
if [[ -d $outDir ]]; then rm -rf $outDir; fi
mkdir -p $outDir

module purge
module load nextflow/24.04.2
module load singularity
source /etc/profile

nextflow run main.nf --resume -profile singularity,test_illumina -entry QUALITY_ALIGN --outdir $outDir/quality
nextflow run main.nf --resume -profile singularity,test_illumina -entry AQUASCOPE --outdir $outDir/aqua
nextflow run main.nf --resume -profile singularity,test_bam -entry FREYJA_ONLY --outdir $outDir/freyja
nextflow run main.nf --resume -profile singularity,test_ont -entry AQUASCOPE --outdir $outDir/ont
