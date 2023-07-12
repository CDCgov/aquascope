
include { FREYJA_VARIANTS   } from '../../../modules/nf-core/modules/nf-core/freyja/variants/main'
include { FREYJA_UPDATE     } from '../../../modules/nf-core/modules/nf-core/freyja/update/main'
include { FREYJA_DEMIX      } from '../../../modules/nf-core/modules/nf-core/freyja/demix/main'
include { FREYJA_BOOT       } from '../../../modules/nf-core/modules/nf-core/freyja/boot/main'

workflow FREYJA_VARIANT_CALLING {

    take:
    ch_bam              // channel: [ val(meta), path(bam) ]
    ch_fasta            // channel: [ val(meta), path(fasta) ]
    ch_val_repeats      // value repeats
    val_db_name         // string db_name
    ch_barcodes         // channel:  [ val(meta), path(barcodes)]
    ch_lineages_meta    // channel:  [ val(meta), path(lineages_meta)]

    main:
    
    ch_versions = Channel.empty()

    //
    // Variant calling
    //
    FREYJA_VARIANTS (
        ch_bam,
        ch_fasta
    )
    ch_freyja_variants = FREYJA_VARIANTS.out.variants
    ch_freyja_depths   = FREYJA_VARIANTS.out.depths

    ch_versions = ch_versions.mix(FREYJA_VARIANTS.out.versions.first())

    //
    // Update the database if none are given.
    //
    
    if (!ch_barcodes || !ch_lineages_meta) {
        FREYJA_UPDATE (
            val_db_name )

        ch_barcodes      = FREYJA_UPDATE.out.barcodes
        ch_lineages_meta = FREYJA_UPDATE.out.lineages_meta

        ch_versions = ch_versions.mix(FREYJA_UPDATE.out.versions.first())
    }

    //
    // demix and define minimum variant abundances
    //
    FREYJA_DEMIX (
        ch_freyja_variants,
        ch_freyja_depths,
        ch_barcodes,
        ch_lineages_meta
    )
    ch_freyja_demix = FREYJA_DEMIX.out.demix
    ch_versions = ch_versions.mix(FREYJA_DEMIX.out.versions.first())


    //
    // Perform bootstrapping to get more accurate estimates of abundancies
    //
    FREYJA_BOOT (
        ch_freyja_variants,
        ch_freyja_depths,
        ch_val_repeats,
        ch_barcodes,
        ch_lineages_meta
    )
    ch_versions = ch_versions.mix(FREYJA_BOOT.out.versions.first())

    emit:
    variants       = FREYJA_VARIANTS.out.variants  // channel: [ val(meta), path(variants_tsv) ]
    depths         = FREYJA_VARIANTS.out.depths    // channel: [ val(meta), path(depths_tsv) ]
    demix          = FREYJA_DEMIX.out.demix        // channel: [ val(meta), path(demix_tsv) ]
    lineages       = FREYJA_BOOT.out.lineages      // channel: [ val(meta), path(lineages_csv) ]
    summarized     = FREYJA_BOOT.out.summarized    // channel: [ val(meta), path(summarized_csv) ]
    barcodes       = ch_barcodes                   // channel: [ val(meta), path(barcodes) ]
    lineages_meta  = ch_lineages_meta              // channel: [ val(meta), path(lineages_meta) ]
    versions       = ch_versions                   // channel: [ path(versions.yml) ]

}

