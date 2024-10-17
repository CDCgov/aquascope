/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/
nextflow.enable.dsl=2

def checkPathParamList = [params.input, params.fasta, params.gff]

for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified! please specify samplesheet containing BAM files only! Run bam_to_samplesheet.py to generate bamfile samplesheet' }


/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS/PLUGINS
========================================================================================
*/
include { softwareVersionsToYAML            } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { paramsSummaryMultiqc              } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { paramsSummaryMap                  } from 'plugin/nf-validation'

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

include { INPUT_BAM_CHECK   	 } from '../modules/local/input_check_bam.nf'
include { FREYJA_VARIANT_CALLING } from '../subworkflows/local/bam_variant_demix_boot_freyja/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'

workflow FREYJA_STANDALONE {
    take: 
    ch_sorted_bam
    
    main:
    ch_genome = params.fasta ? Channel.value(file(params.fasta)) : Channel.empty()

    // MODULE: RUN FREYJA_VARIANT_CALLING
    ch_freyja_variants = Channel.empty()
    ch_freyja_depths = Channel.empty()
    ch_freyja_demix = Channel.empty()
    ch_freyja_lineages = Channel.empty()
    ch_freyja_summarized = Channel.empty()
    ch_versions = Channel.empty()
    FREYJA_VARIANT_CALLING(
        ch_sorted_bam, 
        ch_genome,
        params.freyja_db_name,
        params.freyja_barcodes,
        params.freyja_lineages_meta
    )
    ch_freyja_variants = FREYJA_VARIANT_CALLING.out.variants
    ch_freyja_depths = FREYJA_VARIANT_CALLING.out.depths
    ch_freyja_demix = FREYJA_VARIANT_CALLING.out.demix
    ch_versions = ch_versions.mix(FREYJA_VARIANT_CALLING.out.versions)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(ch_freyja_demix.collect{ it[1] }.ifEmpty([]))
        // Run MultiQC
    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )
    multiqc_report = MULTIQC.out.report.toList()
}