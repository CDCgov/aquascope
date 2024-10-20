//
// Subworkflow: Run Trimming on ONT reads
//

include { SAMTOOLS_AMPLICONCLIP                 } from '../../modules/local/samtools/ampliconclip/main'
include { BAM_SORT_STATS_SAMTOOLS               } from './bam_sort_stats_samtools/main'


params.fasta            = params.fasta ? Channel.value(file( "${params.fasta}")) : Channel.empty()

workflow ONT_TRIMMING   {

    take:
    bam
    val_saverejects
    val_savestats

    main:

    ch_versions             = Channel.empty()
    ch_sorted_bam           = Channel.empty()

    SAMTOOLS_AMPLICONCLIP(
        bam, val_saverejects, val_savestats
    )
    ch_versions = ch_versions.mix(SAMTOOLS_AMPLICONCLIP.out.versions.first())

    BAM_SORT_STATS_SAMTOOLS (
    SAMTOOLS_AMPLICONCLIP.out.bam,
    params.fasta
    )
    ch_versions = ch_versions.mix(BAM_SORT_STATS_SAMTOOLS.out.versions)

    emit:
    //AMPLICONCLIP_BAM
    ampliconclip_bam = SAMTOOLS_AMPLICONCLIP.out.bam                    // channel: [ val(meta), bam   ]

    //SORTED BAM
    bam      = BAM_SORT_STATS_SAMTOOLS.out.bam      // channel: [ val(meta), [ bam ] ]
    bai      = BAM_SORT_STATS_SAMTOOLS.out.bai      // channel: [ val(meta), [ bai ] ]
    csi      = BAM_SORT_STATS_SAMTOOLS.out.csi      // channel: [ val(meta), [ csi ] ]
    stats    = BAM_SORT_STATS_SAMTOOLS.out.stats    // channel: [ val(meta), [ stats ] ]
    flagstat = BAM_SORT_STATS_SAMTOOLS.out.flagstat // channel: [ val(meta), [ flagstat ] ]
    idxstats = BAM_SORT_STATS_SAMTOOLS.out.idxstats // channel: [ val(meta), [ idxstats ] ]

    versions = ch_versions                          // channel: [ versions.yml ]

}