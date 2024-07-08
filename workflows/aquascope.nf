/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/
def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)


// Validate input parameters
WorkflowAquascope.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist

def checkPathParamList = [params.input, params.fasta, params.gff, params.freyja_barcodes, params.freyja_lineages_meta]

for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
/*
========================================================================================
    CONFIG FILES
========================================================================================
*/

ch_multiqc_config        = file("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()

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
include { TRIMMING   as IVAR_TRIMMING_SORTING   } from '../subworkflows/local/trimming.nf'
include { ONT_TRIMMING                          } from '../subworkflows/local/ont_trimming.nf'
include { FREYJA_VARIANT_CALLING                } from '../subworkflows/local/bam_variant_demix_boot_freyja/main'

//
// MODULES
//
include { SAMTOOLS_FAIDX                        } from '../modules/local/samtools/faidx/main'
include { FASTQC     as FASTQC_RAW_SHORT        } from '../modules/nf-core/modules/nf-core/fastqc/main'
include { NANOPLOT   as NANOPLOT_RAW_LONG       } from '../modules/nf-core/modules/nf-core/nanoplot/main'
include { FASTP      as FASTP_SHORT             } from '../modules/nf-core/modules/nf-core/fastp/main'
include { FASTP      as FASTP_LONG              } from '../modules/local/fastp/main'
include { FASTQC     as FASTQC_SHORT_TRIMMED    } from '../modules/nf-core/modules/nf-core/fastqc/main'
include { NANOPLOT   as NANOPLOT_LONG_TRIMMED   } from '../modules/nf-core/modules/nf-core/nanoplot/main'
include { QUALIMAP_BAMQC                        } from '../modules/nf-core/modules/nf-core/qualimap/bamqc/main'
include { MINIMAP2_ALIGN as MINIMAP2_ALIGN_SHORT} from '../modules/local/minimap2/align/main'
include { MINIMAP2_ALIGN as MINIMAP2_ALIGN_LONG } from '../modules/local/minimap2/align/main'
include { REHEADER_BAM                          } from '../modules/local/reheader_bam.nf'
include { IVAR_VARIANTS                         } from '../modules/nf-core/modules/nf-core/ivar/variants/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS           } from '../modules/nf-core/modules/nf-core/custom/dumpsoftwareversions/main'
include { MULTIQC                               } from '../modules/nf-core/modules/nf-core/multiqc/main'


/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary

def multiqc_report = []
ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

workflow AQUASCOPE {
    
    // Initialize channels with known values
    ch_genome = params.fasta ? Channel.value(file(params.fasta)) : Channel.empty()
    ch_gff    = params.gff ? Channel.value(file(params.gff)) : Channel.empty()

    // Initialize channels for other data
    ch_versions = Channel.empty()
    ch_genome_fai = Channel.empty()

    // Validate the Sample File
    SAMPLESHEET_CHECK(ch_input)

    // Proceed only if SAMPLESHEET_CHECK is successful
    if (SAMPLESHEET_CHECK.out.success) {
        println "The samplesheet has been validated, the pipeline will start soon, check samplesheet_validated.csv for more details"
        INPUT_CHECK()

        ch_short_reads = INPUT_CHECK.out.raw_short_reads
        ch_long_reads = INPUT_CHECK.out.raw_long_reads
        ch_raw_bam = INPUT_CHECK.out.raw_bam

        // MODULE: Create Fasta Index file using samtools faidx
        SAMTOOLS_FAIDX(ch_genome)
        ch_genome_fai = SAMTOOLS_FAIDX.out.fai
        ch_versions = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

        // MODULE: FastQC on raw data for initial quality checking for short reads
        FASTQC_RAW_SHORT(ch_short_reads)
        ch_versions = ch_versions.mix(FASTQC_RAW_SHORT.out.versions.first())

        NANOPLOT_RAW_LONG(ch_long_reads)
        ch_versions = ch_versions.mix(NANOPLOT_RAW_LONG.out.versions.first())

        // MODULE: Run FastP for short reads
        ch_trimmed_reads_short = Channel.empty()
        FASTP_SHORT(ch_short_reads, [], false, false)
        ch_trimmed_reads_short = ch_trimmed_reads_short.mix(FASTP_SHORT.out.reads)
        ch_versions = ch_versions.mix(FASTP_SHORT.out.versions.first())

        // MODULE: Run FastP for Long reads
        ch_trimmed_reads_long = Channel.empty()
        FASTP_LONG(ch_long_reads, [], false, false)
        ch_trimmed_reads_long = ch_trimmed_reads_long.mix(FASTP_LONG.out.reads)
        ch_versions = ch_versions.mix(FASTP_LONG.out.versions.first())

        // Quality checking for trimmed reads
        FASTQC_SHORT_TRIMMED(ch_trimmed_reads_short)

        NANOPLOT_LONG_TRIMMED(ch_trimmed_reads_long)

        // MODULE: Align reads against reference genome
        ch_short_align_bam = Channel.empty()
        MINIMAP2_ALIGN_SHORT(ch_trimmed_reads_short, ch_genome, true, false, false)
        ch_short_align_bam = MINIMAP2_ALIGN_SHORT.out.bam
        ch_short_align_bai = MINIMAP2_ALIGN_SHORT.out.bai
        ch_versions = ch_versions.mix(MINIMAP2_ALIGN_SHORT.out.versions.first())

        ch_long_align_bam = Channel.empty()
        MINIMAP2_ALIGN_LONG(ch_trimmed_reads_long, ch_genome, true, false, false)
        ch_long_align_bam = MINIMAP2_ALIGN_LONG.out.bam
        ch_long_align_bai = MINIMAP2_ALIGN_LONG.out.bai

        // Reheader and Sort the INPUT BAM from Ion-Torrent
        ch_rehead_sorted_bam = Channel.empty()
        ch_rehead_sorted_bai = Channel.empty()
        REHEADER_BAM(ch_raw_bam, ch_gff)
        ch_rehead_sorted_bam = REHEADER_BAM.out.reheadered_bam
        ch_rehead_sorted_bai = REHEADER_BAM.out.reheadered_bai
        ch_versions = ch_versions.mix(REHEADER_BAM.out.versions)

        // Combine channels for further processing
        ch_combined_bam = ch_short_align_bam.mix(ch_long_align_bam, ch_rehead_sorted_bam)

        // MODULE : QUALIMAP for post-alignment BAM QC
        QUALIMAP_BAMQC(ch_combined_bam, ch_gff)
        ch_qualimap_multiqc = QUALIMAP_BAMQC.out.results
        ch_versions = ch_versions.mix(QUALIMAP_BAMQC.out.versions.first())

        // MODULE: RUN IVAR_TRIM_SORT - Illumina only
        ch_ivar_sort_bam = Channel.empty()
        ch_ivar_sort_log = Channel.empty()
        IVAR_TRIMMING_SORTING(ch_short_align_bam)
        ch_ivar_sort_bam = IVAR_TRIMMING_SORTING.out.bam
        ch_ivar_sort_log = IVAR_TRIMMING_SORTING.out.log_out
        ch_ivar_stats = IVAR_TRIMMING_SORTING.out.stats
        ch_ivar_bam = IVAR_TRIMMING_SORTING.out.ivar_bam
        ch_versions = ch_versions.mix(IVAR_TRIMMING_SORTING.out.versions)

        // MODULE: RUN SAMTOOLS_AMPLICON_CLIP_SORT - ONT reads only
        ch_amplicon_sort_bam = Channel.empty()
        ONT_TRIMMING(ch_long_align_bam, params.save_cliprejects, params.save_clipstats)
        ch_amplicon_sort_bam = ONT_TRIMMING.out.bam
        ch_amplicon_sort_bai = ONT_TRIMMING.out.bai
        ch_versions = ch_versions.mix(ONT_TRIMMING.out.versions)

        // Combine sorted BAM files
        ch_sorted_bam = ch_ivar_sort_bam.mix(ch_rehead_sorted_bam)
        ch_sorted_mixedbam = ch_sorted_bam.mix(ch_amplicon_sort_bam)

        // MODULE: Identify variants with iVar
        ch_ivar_vcf = Channel.empty()
        IVAR_VARIANTS(
            ch_sorted_bam, 
            ch_genome, // Assuming the reference and this are the same 
            ch_genome_fai,
            ch_gff, 
            params.save_mpileup // default is false, change it to true in nextflow.config file
        )
        ch_ivar_vcf = IVAR_VARIANTS.out.tsv
        ch_versions = ch_versions.mix(IVAR_VARIANTS.out.versions.first())

        // MODULE: RUN FREYJA_VARIANT_CALLING
        ch_freyja_variants = Channel.empty()
        ch_freyja_depths = Channel.empty()
        ch_freyja_demix = Channel.empty()
        ch_freyja_lineages = Channel.empty()
        ch_freyja_summarized = Channel.empty()
        FREYJA_VARIANT_CALLING(
            ch_sorted_mixedbam, 
            ch_genome,
            params.freyja_db_name,
            params.freyja_barcodes,
            params.freyja_lineages_meta
        )
        ch_freyja_variants = FREYJA_VARIANT_CALLING.out.variants
        ch_freyja_depths = FREYJA_VARIANT_CALLING.out.depths
        ch_freyja_demix = FREYJA_VARIANT_CALLING.out.demix
        ch_versions = ch_versions.mix(FREYJA_VARIANT_CALLING.out.versions)

        // Workflow reporting
        workflow_summary = WorkflowAquascope.paramsSummaryMultiqc(workflow, summary_params)
        ch_workflow_summary = Channel.value(workflow_summary)
        methods_description = WorkflowAquascope.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description)
        ch_methods_description = Channel.value(methods_description)

        ch_multiqc_files = Channel.empty()
        ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
        ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
        ch_multiqc_files = ch_multiqc_files.mix(FASTQC_RAW_SHORT.out.zip.collect{ it[1] }.ifEmpty([]))
        ch_multiqc_files = ch_multiqc_files.mix(FASTP_SHORT.out.json.collect{ it[1] }.ifEmpty([]))
        ch_multiqc_files = ch_multiqc_files.mix(FASTP_LONG.out.json.collect{ it[1] }.ifEmpty([]))
        ch_multiqc_files = ch_multiqc_files.mix(FASTQC_SHORT_TRIMMED.out.zip.collect{ it[1] }.ifEmpty([]))
        ch_multiqc_files = ch_multiqc_files.mix(ch_qualimap_multiqc.collect{ it[1] }.ifEmpty([]))
        ch_multiqc_files = ch_multiqc_files.mix(ch_freyja_demix.collect{ it[1] }.ifEmpty([]))
        ch_multiqc_files = ch_multiqc_files.mix(ch_ivar_stats.collect{ it[1] }.ifEmpty([]))

        // Run MultiQC
        MULTIQC (
            ch_multiqc_files.collect(),
            ch_multiqc_config.toList(),
            ch_multiqc_custom_config.toList(),
            ch_multiqc_logo.toList()
        )
        multiqc_report = MULTIQC.out.report.toList()
    } else {
    println "The samplesheet validation failed. Please check the input samplesheet and try again."
    exit 1
    }
}

// ========================================================================================
//     COMPLETION EMAIL AND SUMMARY
// ========================================================================================
workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}
