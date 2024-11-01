//
// Sort, index BAM file and run samtools stats, flagstat and idxstats
//

include { SAMTOOLS_SORT      } from '../../../modules/nf-core/samtools/sort/main'
include { SAMTOOLS_INDEX     } from '../../../modules/nf-core/samtools/index/main'
include { SAMTOOLS_STATS    } from '../../../modules/nf-core/samtools/stats/main'
include { SAMTOOLS_IDXSTATS } from '../../../modules/nf-core/samtools/idxstats/main'
include { SAMTOOLS_FLAGSTAT } from '../../../modules/nf-core/samtools/flagstat/main'


workflow BAM_SORT_STATS_SAMTOOLS {
    take:
    ch_bam   // channel: [ val(meta), [ bam ] ]
    ch_fasta // channel: [ fasta ]

    main:

    ch_versions = Channel.empty()

    SAMTOOLS_SORT ( ch_bam )
    ch_versions = ch_versions.mix(SAMTOOLS_SORT.out.versions.first())

    SAMTOOLS_INDEX ( SAMTOOLS_SORT.out.bam )
    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions.first())

    SAMTOOLS_SORT.out.bam
        .join(SAMTOOLS_INDEX.out.bai, by: [0], remainder: true)
        .join(SAMTOOLS_INDEX.out.csi, by: [0], remainder: true)
        .map {
            meta, bam, bai, csi ->
                if (bai) {
                    [ meta, bam, bai ]
                } else {
                    [ meta, bam, csi ]
                }
        }
        .set { ch_bam_bai }

    SAMTOOLS_STATS ( ch_bam_bai, ch_fasta )
    ch_versions = ch_versions.mix(SAMTOOLS_STATS.out.versions)

    SAMTOOLS_FLAGSTAT ( ch_bam_bai )
    ch_versions = ch_versions.mix(SAMTOOLS_FLAGSTAT.out.versions)

    SAMTOOLS_IDXSTATS ( ch_bam_bai )
    ch_versions = ch_versions.mix(SAMTOOLS_IDXSTATS.out.versions)

    emit:
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    stats    = SAMTOOLS_STATS.out.stats       // channel: [ val(meta), path(stats) ]
    flagstat = SAMTOOLS_FLAGSTAT.out.flagstat // channel: [ val(meta), path(flagstat) ]
    idxstats = SAMTOOLS_IDXSTATS.out.idxstats // channel: [ val(meta), path(idxstats) ]

    versions = ch_versions                     // channel: [ versions.yml ]
}