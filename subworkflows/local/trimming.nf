//
// Subworkflow: Run Trimming
//

include { IVAR_TRIM                             } from '../../modules/nf-core/ivar/trim/main'
include { BAM_SORT_STATS_SAMTOOLS               } from './bam_sort_stats_samtools/main'


ch_genome = params.fasta ? Channel.value(file(params.fasta)) : Channel.empty()

workflow TRIMMING   {

    take:
    bam

    main:

    ch_versions             = Channel.empty()
    ch_sorted_bam           = Channel.empty()

    IVAR_TRIM(
        bam
    )
    ch_versions = ch_versions.mix(IVAR_TRIM.out.versions)

    BAM_SORT_STATS_SAMTOOLS (
    IVAR_TRIM.out.bam,
    ch_genome
    )
    ch_versions = ch_versions.mix(BAM_SORT_STATS_SAMTOOLS.out.versions)

    emit:
    ivar_bam = IVAR_TRIM.out.bam                    // channel: [ val(meta), bam   ]
    log_out  = IVAR_TRIM.out.log                    // channel: [ val(meta), log   ]

    bam      = BAM_SORT_STATS_SAMTOOLS.out.bam      // channel: [ val(meta), [ bam ] ]
    bai      = BAM_SORT_STATS_SAMTOOLS.out.bai      // channel: [ val(meta), [ bai ] ]
    csi      = BAM_SORT_STATS_SAMTOOLS.out.csi      // channel: [ val(meta), [ csi ] ]
    stats    = BAM_SORT_STATS_SAMTOOLS.out.stats    // channel: [ val(meta), [ stats ] ]
    flagstat = BAM_SORT_STATS_SAMTOOLS.out.flagstat // channel: [ val(meta), [ flagstat ] ]
    idxstats = BAM_SORT_STATS_SAMTOOLS.out.idxstats // channel: [ val(meta), [ idxstats ] ]

    versions = ch_versions                          // channel: [ versions.yml ]

}