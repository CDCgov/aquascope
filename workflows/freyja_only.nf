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
include { methodsDescriptionText            } from '../subworkflows/local/utils_nfcore_aquascope_pipeline'

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

include { INPUT_BAM_CHECK   	 } from '../modules/local/input_check_bam.nf'
include { FREYJA_VARIANT_CALLING } from '../subworkflows/local/freyja_variant_demix_update/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'

workflow runFreyja {
    take: 
    ch_sorted_bam
    ch_multiqc_files
    
    main:
    ch_genome = params.fasta ? Channel.value(file(params.fasta)) : Channel.empty()

    // MODULE: RUN FREYJA_VARIANT_CALLING
    ch_freyja_variants = Channel.empty()
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
    ch_freyja_demix = FREYJA_VARIANT_CALLING.out.demix
    ch_versions = ch_versions.mix(FREYJA_VARIANT_CALLING.out.versions)

    // Run MultiQC
    ch_multiqc_report = Channel.empty()
    if (!params.skip_multiqc) {    
        // Add FREYJA outputs
        ch_multiqc_files = ch_multiqc_files.mix(ch_freyja_demix.collect{ it[1] }.ifEmpty([]))
        
        // set configs, defaults
        ch_multiqc_config        = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
        ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()
        ch_multiqc_logo          = params.multiqc_logo   ? Channel.fromPath(params.multiqc_logo)   : Channel.empty()
        summary_params           = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")
        ch_workflow_summary      = Channel.value(paramsSummaryMultiqc(summary_params))
        ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
        ch_methods_description   = Channel.value(methodsDescriptionText(ch_multiqc_custom_methods_description))
        ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
        ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
        
        // Run MultiQC
        MULTIQC (
            ch_multiqc_files.collect(),
            ch_multiqc_config.toList(),
            ch_multiqc_custom_config.toList(),
            ch_multiqc_logo.toList()
        )
        ch_multiqc_report = MULTIQC.out.report.toList()
    }

     emit:
        multiqc_report          = ch_multiqc_report
}