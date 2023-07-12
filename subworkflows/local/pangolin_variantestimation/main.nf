//
// Run SAMtools stats, flagstat and idxstats
//

include { BCFTOOLS_MPILEUP      } from '../../../modules/nf-core/modules/nf-core/bcftools/mpileup/main'
include { BCFTOOLS_CONSENSUS    } from '../../../modules/nf-core/modules/nf-core/bcftools/consensus/main'
include { PANGOLIN              } from '../../../modules/nf-core/modules/nf-core/pangolin/main'

workflow PANGOLIN_VARIANTESTIMATION {
    
    take:
    bam      // channel: [ val(meta), path(bam), path(bai) ]
    genome   // channel: [ path(fasta) ]

    main:
    
    ch_versions            = Channel.empty()
    ch_mpileup_stats       = Channel.empty()
    BCFTOOLS_MPILEUP ( bam.map{ meta, bam_file -> [ meta, bam_file, [] ] },
    genome,true
    )
    ch_mpileup_vcf         = BCFTOOLS_MPILEUP.out.vcf
    ch_mpileup_tbi         = BCFTOOLS_MPILEUP.out.tbi
    ch_mpileup_stats       = BCFTOOLS_MPILEUP.out.stats
    ch_versions            = ch_versions.mix(BCFTOOLS_MPILEUP.out.versions)

    ch_consensus_fasta     = Channel.empty()
    ch_input_consensus     = ch_mpileup_vcf.join(ch_mpileup_tbi, by:[0])
    BCFTOOLS_CONSENSUS (ch_input_consensus, genome)
    ch_consensus_fasta     = BCFTOOLS_CONSENSUS.out.fasta

    ch_pangolin_report     = Channel.empty()
    PANGOLIN (ch_consensus_fasta)
    ch_pangolin_report     = PANGOLIN.out.report
    
    emit:
    fasta    = ch_consensus_fasta             // channel: [ val(meta), path(fasta) ]
    stats    = ch_mpileup_stats
    report   = ch_pangolin_report             // channel: [val(meta),  path(report)]
    versions = ch_versions                    // channel: [ path(versions.yml) ]

}