
include { FREYJA_VARIANTS   } from '../../../modules/local/freyja/variants/main'
include { FREYJA_UPDATE     } from '../../../modules/local/freyja/update/main'
include { FREYJA_DEMIX      } from '../../../modules/local/freyja/demix/main'

workflow FREYJA_VARIANT_CALLING {

    take:
    ch_bam              // channel: [ val(meta), path(bam) ]
    ch_fasta            // channel: [ val(meta), path(fasta) ]
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

    ch_versions = ch_versions.mix(FREYJA_VARIANTS.out.versions)

    //
    // Update the database if none are given.
    //
    
    if (!ch_barcodes || !ch_lineages_meta) {
        FREYJA_UPDATE (
            val_db_name )

        ch_barcodes      = FREYJA_UPDATE.out.barcodes
        ch_lineages_meta = FREYJA_UPDATE.out.lineages_meta

        ch_versions = ch_versions.mix(FREYJA_UPDATE.out.versions)
    }

    //
    // demix and define minimum variant abundances
    //
    FREYJA_DEMIX (
        ch_freyja_variants,
        ch_barcodes,
        ch_lineages_meta
    )
    ch_freyja_demix = FREYJA_DEMIX.out.demix
    ch_versions = ch_versions.mix(FREYJA_DEMIX.out.versions)

    emit:
    variants       = FREYJA_VARIANTS.out.variants  // channel: [ val(meta), path(variants_tsv) ]
    demix          = FREYJA_DEMIX.out.demix        // channel: [ val(meta), path(demix_tsv) ]
    barcodes       = ch_barcodes                   // channel: [ val(meta), path(barcodes) ]
    lineages_meta  = ch_lineages_meta              // channel: [ val(meta), path(lineages_meta) ]
    versions       = ch_versions                   // channel: [ path(versions.yml) ]

}

