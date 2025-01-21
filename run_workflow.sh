# set up paths, files

# set up modules
module purge
module load nextflow/24.04.2
module load singularity
source /etc/profile

# housekeeping
flag=$1
outDir=$2
if [[ -z $outDir ]]; then echo "outDir is required!"; exit; fi
if [[ ! -d $outDir ]]; then mkdir -p $outDir; fi

# run locally on biolinux
if [[ $flag == "biolinux" ]]; then
	nextflow run main.nf \
	-entry AQUASCOPE \
	-profile test_illumina,singularity \
	-work-dir $outDir/work \
	--outdir $outDir \
	-resume
fi
