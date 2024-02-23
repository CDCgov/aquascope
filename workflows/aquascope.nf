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

def checkPathParamList = [ params.input, params.fasta, params.bed, params.gff, params.freyja_barcodes, params.freyja_lineages_meta]

for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters

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
include { INPUT_CHECK                           } from '../subworkflows/local/input_check.nf'
include { TRIMMING   as IVAR_TRIMMING_SORTING   } from '../subworkflows/local/trimming.nf'
include { FREYJA_VARIANT_CALLING                } from '../subworkflows/local/bam_variant_demix_boot_freyja/main'

//
// MODULES
//
include { SAMTOOLS_FAIDX                        } from '../modules/local/samtools/faidx/main'
include { FASTQC     as FASTQC_RAW_SHORT        } from '../modules/nf-core/modules/nf-core/fastqc/main'
include { NANOPLOT   as NANOPLOT_RAW_LONG       } from '../modules/nf-core/modules/nf-core/nanoplot/main'
include { FASTP      as FASTP_SHORT             } from '../modules/nf-core/modules/nf-core/fastp/main'
include { FASTP      as FASTP_LONG              } from '../modules/local/fastp/main'
//include { CHOPPER                               } from '../modules/nf-core/modules/nf-core/chopper/main'
include { FASTQC     as FASTQC_SHORT_TRIMMED    } from '../modules/nf-core/modules/nf-core/fastqc/main'
include { NANOPLOT   as NANOPLOT_LONG_TRIMMED   } from '../modules/nf-core/modules/nf-core/nanoplot/main'
include { KRAKEN2_KRAKEN2 as KRAKEN2_STD        } from '../modules/nf-core/modules/nf-core/kraken2/kraken2/main'
include { QUALIMAP_BAMQC                        } from '../modules/nf-core/modules/nf-core/qualimap/bamqc/main'
include { MINIMAP2_ALIGN                        } from '../modules/local/minimap2/align/main'
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

    // Initialize empty channels and set value channels from params
    ch_versions             = Channel.empty()
    ch_reads_minimap        = Channel.empty()
    ch_genome_fai           = Channel.empty()
    ch_genome               = params.fasta                ? Channel.value(file( "${params.fasta}" ))                : Channel.empty()        
    
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    INPUT_CHECK ()
    ch_short_reads           = INPUT_CHECK.out.raw_short_reads
    ch_long_reads            = INPUT_CHECK.out.raw_long_reads
    ch_raw_bam               = INPUT_CHECK.out.raw_bam


    // MODULE: PICARD SAMTOFASTQ 


    // take the output and channel it to fastp and fastqc
    
    // MODULE: Create Fasta Index file using samtools faidx
    SAMTOOLS_FAIDX (
        ch_genome 
    )
    ch_genome_fai       = SAMTOOLS_FAIDX.out.fai
    ch_versions         = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    
    // 
    // MODULE: FastQC on raw data for initial quality checking for short reads
    //
    FASTQC_RAW_SHORT (
        ch_short_reads
    )
    ch_versions = ch_versions.mix(FASTQC_RAW_SHORT.out.versions.first())

    NANOPLOT_RAW_LONG (
        ch_long_reads
    )
    ch_versions = ch_versions.mix(NANOPLOT_RAW_LONG.out.versions.first())

    // 
    // MODULE: Run FastP for short reads
    //
    ch_trimmed_reads_short = Channel.empty()
    FASTP_SHORT (
        ch_short_reads, [], false, false
    )
    ch_trimmed_reads_short = ch_trimmed_reads_short.mix(FASTP_SHORT.out.reads)
    ch_versions = ch_versions.mix(FASTP_SHORT.out.versions.first())

    // 
    // MODULE: Run FastP for Long reads
    //
    ch_trimmed_reads_long = Channel.empty()
    FASTP_LONG (
        ch_long_reads, [], false, false
    )
        ch_trimmed_reads_long = ch_trimmed_reads_long.mix(FASTP_LONG.out.reads)

    //
    // MODULE: Run Chopper for Long reads
    //
    
    //CHOPPER(
      //  ch_long_reads
    //)
    // 
    // MODULE: FastQC for final quality checking
    //
    
    FASTQC_SHORT_TRIMMED (
        ch_trimmed_reads_short
    )

    // 
    // MODULE: NANOPLOT_TRIMMED for final quality checking
    //

    NANOPLOT_LONG_TRIMMED (
        ch_trimmed_reads_long
        )
    
    // 
    // MODULE: KRAKEN2 to check for human and bacterial reads
    ch_trimmed_reads = Channel.empty()

    ch_kraken2_multiqc = Channel.empty()

    if(params.kraken != false){
        KRAKEN2_STD (
                ch_trimmed_reads_short,
                params.kraken_db_std,
                true,
                true
            )
        ch_kraken2_multiqc = KRAKEN2_STD.out.report

    }
    // 
    // MODULE: Align reads against reference genome
    //
    ch_trimmed_reads = ch_trimmed_reads_short.mix(ch_trimmed_reads_long)
    ch_align_bam = Channel.empty()
    ch_align_bai = Channel.empty()
    
    MINIMAP2_ALIGN (
        ch_trimmed_reads, ch_genome, true, false, false 
    )
    ch_align_bam            = MINIMAP2_ALIGN.out.bam
    ch_versions             = ch_versions.mix(MINIMAP2_ALIGN.out.versions.first())

    //
    // MODULE: Rehader and Sort the INPUT BAM from Ion-Torrent
    //
    ch_rehead_sorted_bam = Channel.empty()   
    REHEADER_BAM (
        ch_raw_bam
    )
    ch_rehead_sorted_bam = REHEADER_BAM.out.reheadered_bam
    ch_versions = ch_versions.mix(REHEADER_BAM.out.versions)

    ch_combined_sort_bam = ch_align_bam.mix(ch_rehead_sorted_bam) //Combining NY bam with all other samples for usage in Qualimap only.
    //
    // MODULE : QUALIMAP for post-alignment BAM QC
    //

    QUALIMAP_BAMQC (
                ch_combined_sort_bam,
                params.bed
            )
    ch_qualimap_multiqc = QUALIMAP_BAMQC.out.results
    ch_versions = ch_versions.mix(QUALIMAP_BAMQC.out.versions.first())

    // 
    // MODULE: RUN IVAR_TRIM_SORT - Illumina, ONT, PacBio only
    //

    ch_ivar_sort_bam = Channel.empty()
    ch_ivar_sort_bai = Channel.empty()
    ch_ivar_bam      = Channel.empty()

    IVAR_TRIMMING_SORTING(
        ch_align_bam
    )
    ch_ivar_sort_bam   = IVAR_TRIMMING_SORTING.out.bam
    ch_ivar_stats      = IVAR_TRIMMING_SORTING.out.stats
    ch_ivar_bam        = IVAR_TRIMMING_SORTING.out.ivar_bam
    ch_versions        = ch_versions.mix(IVAR_TRIMMING_SORTING.out.versions)


    //For now, we are mixing IVAR_TRIMMING_SORTING with Reheadered IonTorrent bam file

    ch_sorted_mixedbam = ch_ivar_sort_bam.mix(
        ch_rehead_sorted_bam
        ) // Here we are mixing IVAR trimmed illumina & long reads to Iontorrent bam files for usage in variant calling

    // 
    // MODULE: Identify variants with iVar
    //

    ch_ivar_vcf = Channel.empty()
    IVAR_VARIANTS(
        ch_sorted_mixedbam, 
        ch_genome,          // Assuming the reference and this are the same 
        ch_genome_fai,
        params.gff, 
        params.save_mpileup // default is false, change it to true in nextflow.config file
    )
    ch_ivar_vcf     = IVAR_VARIANTS.out.tsv
    ch_versions = ch_versions.mix(IVAR_VARIANTS.out.versions.first())


    // 
    // MODULE: RUN FREYJA_VARIANT_CALLING
    //
    
    ch_freyja_variants      = Channel.empty()
    ch_freyja_depths        = Channel.empty()
    ch_freyja_demix         = Channel.empty()
    ch_freyja_lineages      = Channel.empty()
    ch_freyja_summarized    = Channel.empty()
    FREYJA_VARIANT_CALLING(
        ch_sorted_mixedbam, 
        ch_genome,
       // params.freyja_repeats,
        params.freyja_db_name,
        params.freyja_barcodes,
        params.freyja_lineages_meta
    )
    ch_freyja_variants      = FREYJA_VARIANT_CALLING.out.variants
    ch_freyja_depths        = FREYJA_VARIANT_CALLING.out.depths
    ch_freyja_demix         = FREYJA_VARIANT_CALLING.out.demix
    //ch_freyja_lineages      = FREYJA_VARIANT_CALLING.out.lineages
   // ch_freyja_summarized    = FREYJA_VARIANT_CALLING.out.summarized
    ch_versions             = ch_versions.mix(FREYJA_VARIANT_CALLING.out.versions)

/*     // MODULE: Pipeline reporting
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
 */
    // MODULE: MultiQC
    workflow_summary    = WorkflowAquascope.paramsSummaryMultiqc(workflow, summary_params)
    ch_workflow_summary = Channel.value(workflow_summary)
    methods_description    = WorkflowAquascope.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description)
    ch_methods_description = Channel.value(methods_description)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
    //ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.collect())
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_RAW_SHORT.out.zip.collect{it[1]}.ifEmpty([]))
    //ch_multiqc_files = ch_multiqc_files.mix(NANOPLOT_RAW_LONG.out.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(FASTP_SHORT.out.json.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(FASTP_LONG.out.json.collect{it[1]}.ifEmpty([]))
    //ch_multiqc_files = ch_multiqc_files.mix(CHOPPER.out.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_SHORT_TRIMMED.out.zip.collect{it[1]}.ifEmpty([]))
    //ch_multiqc_files = ch_multiqc_files.mix(NANOPLOT_LONG_TRIMMED.out.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(ch_kraken2_multiqc.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(ch_qualimap_multiqc.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(ch_freyja_demix.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(ch_ivar_stats.collect{it[1]}.ifEmpty([]))


    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )
    multiqc_report       = MULTIQC.out.report.toList()
}

// /*
// ========================================================================================
//     COMPLETION EMAIL AND SUMMARY
// ========================================================================================
// */

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}
/*
========================================================================================
    THE END
========================================================================================
*/
