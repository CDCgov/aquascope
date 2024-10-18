#!/usr/bin/env nextflow
/*
========================================================================================
    NWSS/aquascope
========================================================================================
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

// Initialises the workflow and validates parameters
include  { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_aquascope_pipeline'
include  { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_aquascope_pipeline'
include  { getGenomeAttribute      } from './subworkflows/local/utils_nfcore_aquascope_pipeline'
/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

// Include the workflows from their respective files
include { runQualityAlign       } from './workflows/quality_align'
include { runFreyja             } from './workflows/freyja_only'
include { runAquascope          } from './workflows/aquascope'

/*
========================================================================================
    NAMED MODULES FOR PIPELINE
========================================================================================
*/

// Include the workflows from their respective files
include { INPUT_BAM_CHECK       } from './modules/local/input_check_bam.nf'

//
// WORKFLOW: Run main nf-core/aquascope analysis pipeline
// **** QUALITY_ALIGN PIPELINE ONLY RUNS THE PIPELINE UNTIL FREYJA VARIANT ESTIMATION **** //
//
workflow QUALITY_ALIGN {
    
    main:
    // **** AQUASCOPE DCIPHER PIPELINE - STAGE 1 produces only sorted BAM files, doesn't run VARIANT CALLING/ESTIMATIONS (IVAR AND FREYJA) **** //
    //
    // SUBWORKFLOW: Run initialization tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.help,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir
    )

    runQualityAlign()

    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
        runQualityAlign.out.multiqc_report
    )
}

//
// WORKFLOW: Run Freyja standalone analysis
// **** FREYJA_ONLY PIPELINE ONLY RUNS FREYJA VARIANT ESTIMATION FROM AN INPUT BAM SAMPLESHEET **** //
//
workflow FREYJA_ONLY {
    main:
    //
    // SUBWORKFLOW: Run initialization tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.help,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir
    )
    // 
    // Run the BAM check on inputs
    // Run the FREYJA workflow
    INPUT_BAM_CHECK ()
    ch_sorted_bam = INPUT_BAM_CHECK.out.bam_files
    
    // Set empty channel
    multiqc_files=Channel.empty()

    // Run variant calling
    runFreyja(
        ch_sorted_bam,
        multiqc_files)

    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
        runFreyja.out.multiqc_report
    )
}

//
// WORKFLOW: Run both QUALITY_ALIGN and FREYJA_ONLY
//
workflow AQUASCOPE {
    // **** AQUASCOPE COMPLETE PIPELINE **** //

    main:
    //
    // SUBWORKFLOW: Run initialization tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.help,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir
    )

    // RUN THE QA
    runQualityAlign()

    // RUN THE FREYJA 
    runFreyja(
        runQualityAlign.out.sorted_mixedbam,
        runQualityAlign.out.multiqc_files
    )

    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
        runFreyja.out.multiqc_report
    )
}

