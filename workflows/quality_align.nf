/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/

nextflow.enable.dsl=2

def checkPathParamList = [params.input, params.fasta, params.gff]

for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS/PLUGINS
========================================================================================
*/
include { softwareVersionsToYAML            } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { paramsSummaryMultiqc              } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { paramsSummaryMap                  } from 'plugin/nf-schema'
include { methodsDescriptionText            } from '../subworkflows/local/utils_nfcore_aquascope_pipeline'

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// SUBWORKFLOWS
//
include { SAMPLESHEET_CHECK                     } from '../modules/local/samplesheet_check.nf'
include { INPUT_CHECK                           } from '../subworkflows/local/input_check.nf'
include { ONT_TRIMMING                          } from '../subworkflows/local/ont_trimming.nf'
include { TRIMMING   as IVAR_TRIMMING_SORTING   } from '../subworkflows/local/trimming.nf'

//
// MODULES
//
include { FASTQC     as FASTQC_RAW_SHORT        } from '../modules/nf-core/fastqc/main'
include { NANOPLOT   as NANOPLOT_RAW_LONG       } from '../modules/nf-core/nanoplot/main'
include { FASTP      as FASTP_SHORT             } from '../modules/nf-core/fastp/main'
include { FASTP      as FASTP_LONG              } from '../modules/local/fastp/main'
include { FASTQC     as FASTQC_SHORT_TRIMMED    } from '../modules/nf-core/fastqc/main'
include { NANOPLOT   as NANOPLOT_LONG_TRIMMED   } from '../modules/nf-core/nanoplot/main'
include { QUALIMAP_BAMQC                        } from '../modules/nf-core/qualimap/bamqc/main'
include { MINIMAP2_ALIGN as MINIMAP2_ALIGN_SHORT} from '../modules/local/minimap2/align/main'
include { MINIMAP2_ALIGN as MINIMAP2_ALIGN_LONG } from '../modules/local/minimap2/align/main'
include { REHEADER_BAM                          } from '../modules/local/reheader_bam.nf'
include { MULTIQC                               } from '../modules/nf-core/multiqc/main'


/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow runQualityAlign {
    
    // Initialize channels with known values
    ch_genome = params.fasta ? Channel.value(file(params.fasta)) : Channel.empty()
    ch_gff    = params.gff ? Channel.value(file(params.gff)) : Channel.empty()

    // Initialize channels for other data
    ch_versions = Channel.empty()

    // Validate the Sample File
    SAMPLESHEET_CHECK(ch_input)

    // Proceed only if SAMPLESHEET_CHECK is successful
    if (SAMPLESHEET_CHECK.out.success) {
        println "The samplesheet has been validated, the pipeline will start soon, check samplesheet_validated.csv for more details"
        INPUT_CHECK()

        ch_short_reads = INPUT_CHECK.out.raw_short_reads
        ch_long_reads = INPUT_CHECK.out.raw_long_reads
        ch_raw_bam = INPUT_CHECK.out.raw_bam

        // MODULE: FastQC on raw data for initial quality checking for short reads
        FASTQC_RAW_SHORT(ch_short_reads)
        ch_versions = ch_versions.mix(FASTQC_RAW_SHORT.out.versions.ifEmpty(null))

        NANOPLOT_RAW_LONG(ch_long_reads)
        ch_versions = ch_versions.mix(NANOPLOT_RAW_LONG.out.versions.ifEmpty(null))

        // MODULE: Run FastP for short reads
        ch_trimmed_reads_short = Channel.empty()
        FASTP_SHORT(ch_short_reads, [], false, false, false)
        ch_trimmed_reads_short = ch_trimmed_reads_short.mix(FASTP_SHORT.out.reads)
        ch_versions = ch_versions.mix(FASTP_SHORT.out.versions.ifEmpty(null))

        // MODULE: Run FastP for Long reads
        ch_trimmed_reads_long = Channel.empty()
        FASTP_LONG(ch_long_reads, [], false, false)
        ch_trimmed_reads_long = ch_trimmed_reads_long.mix(FASTP_LONG.out.reads)
        ch_versions = ch_versions.mix(FASTP_LONG.out.versions.ifEmpty(null))

        // Quality checking for trimmed reads
        FASTQC_SHORT_TRIMMED(ch_trimmed_reads_short)
        NANOPLOT_LONG_TRIMMED(ch_trimmed_reads_long)

        // MODULE: Align reads against reference genome
        ch_short_align_bam = Channel.empty()
        MINIMAP2_ALIGN_SHORT(ch_trimmed_reads_short, ch_genome, true, false, false)
        ch_short_align_bam = MINIMAP2_ALIGN_SHORT.out.bam
        ch_versions = ch_versions.mix(MINIMAP2_ALIGN_SHORT.out.versions.ifEmpty(null))

        ch_long_align_bam = Channel.empty()
        MINIMAP2_ALIGN_LONG(ch_trimmed_reads_long, ch_genome, true, false, false)
        ch_long_align_bam = MINIMAP2_ALIGN_LONG.out.bam

        // Reheader and Sort the INPUT BAM from Ion-Torrent
        ch_rehead_sorted_bam = Channel.empty()
        REHEADER_BAM(ch_raw_bam, ch_gff)
        ch_rehead_sorted_bam = REHEADER_BAM.out.reheadered_bam
        ch_versions = ch_versions.mix(REHEADER_BAM.out.versions.ifEmpty(null))

        // Combine channels for further processing
        ch_combined_bam = ch_short_align_bam.mix(ch_long_align_bam, ch_rehead_sorted_bam)

        // MODULE : QUALIMAP for post-alignment BAM QC
        QUALIMAP_BAMQC(ch_combined_bam, ch_gff)
        ch_qualimap_multiqc = QUALIMAP_BAMQC.out.results
        ch_versions = ch_versions.mix(QUALIMAP_BAMQC.out.versions.ifEmpty(null))

        // MODULE: RUN IVAR_TRIM_SORT - Illumina only
        ch_ivar_sort_bam = Channel.empty()
        IVAR_TRIMMING_SORTING(ch_short_align_bam)
        ch_ivar_sort_bam = IVAR_TRIMMING_SORTING.out.bam
        ch_versions = ch_versions.mix(IVAR_TRIMMING_SORTING.out.versions.ifEmpty(null))

        // MODULE: RUN SAMTOOLS_AMPLICON_CLIP_SORT - ONT reads only
        ch_amplicon_sort_bam = Channel.empty()
        ONT_TRIMMING(ch_long_align_bam, params.save_cliprejects, params.save_clipstats)
        ch_amplicon_sort_bam = ONT_TRIMMING.out.bam
        ch_amplicon_sort_bai = ONT_TRIMMING.out.bai
        ch_versions = ch_versions.mix(ONT_TRIMMING.out.versions.ifEmpty(null))

        // Combine sorted BAM files
        ch_sorted_bam = ch_ivar_sort_bam.mix(ch_rehead_sorted_bam)
        ch_sorted_mixedbam = ch_sorted_bam.mix(ch_amplicon_sort_bam)

        // MODULE: MULTIQC
        if (!params.skip_multiqc) {    
            // set empty
            ch_multiqc_report = Channel.empty()
            ch_multiqc_files = Channel.empty()
            
            // merge files
            ch_multiqc_files = ch_multiqc_files.mix(FASTQC_RAW_SHORT.out.zip.collect{ it[1] }.ifEmpty([]))
            ch_multiqc_files = ch_multiqc_files.mix(FASTP_SHORT.out.json.collect{ it[1] }.ifEmpty([]))
            ch_multiqc_files = ch_multiqc_files.mix(FASTP_LONG.out.json.collect{ it[1] }.ifEmpty([]))
            ch_multiqc_files = ch_multiqc_files.mix(FASTQC_SHORT_TRIMMED.out.zip.collect{ it[1] }.ifEmpty([]))
            ch_multiqc_files = ch_multiqc_files.mix(ch_qualimap_multiqc.collect{ it[1] }.ifEmpty([]))

            // set configs, defaults
            ch_multiqc_config        = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
            ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()
            ch_multiqc_logo          = params.multiqc_logo   ? Channel.fromPath(params.multiqc_logo)   : Channel.empty()
            summary_params           = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")
            ch_workflow_summary      = Channel.value(paramsSummaryMultiqc(summary_params))
            ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
                file(params.multiqc_methods_description, checkIfExists: true) :
                file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
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
    } else {
        println "The samplesheet validation failed. Please check the input samplesheet and try again."
        exit 1
    }

    emit:
        sorted_mixedbam         = ch_sorted_mixedbam
        multiqc_files           = ch_multiqc_files
        multiqc_report          = ch_multiqc_report
}