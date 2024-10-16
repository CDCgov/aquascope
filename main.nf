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
include { AQUASCOPE_DCIPHER } from './workflows/aquascope_dcipher'
include { AQUASCOPE         } from './workflows/aquascope'
include { FREYJA_STANDALONE } from './workflows/freyja_standalone'


//
// WORKFLOW: Run main nf-core/aquascope analysis pipeline
//
workflow NFCORE_AQUASCOPE_DCIPHER {
    
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

    AQUASCOPE_DCIPHER()

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
        AQUASCOPE_DCIPHER.out.multiqc_report
    )
}

workflow NFCORE_AQUASCOPE {
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

    AQUASCOPE()

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
        AQUASCOPE.out.multiqc_report
    )
}

// **** FREYJA STANDALONE PIPELINE ONLY RUNS FREYJA VARIANT ESTIMATION FROM AN INPUT BAM SAMPLESHEET **** //
//
// WORKFLOW: Run Freyja standalone analysis
//
workflow NFCORE_FREYJA_STANDALONE {
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
    
    FREYJA_STANDALONE()
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
        FREYJA_STANDALONE.out.multiqc_report
    )
}

/*
========================================================================================
    RUN THE SELECTED WORKFLOW
========================================================================================
*/

workflow {
    if (params.workflow == 'aquascope') {
        NFCORE_AQUASCOPE()
    } else if (params.workflow == 'freyja_standalone') {
        NFCORE_FREYJA_STANDALONE()
    } else if (params.workflow   == 'aquascope_dcipher') {
        NFCORE_AQUASCOPE_DCIPHER()
    } else {
        error "Unknown workflow specified: ${params.workflow}. Valid options are 'aquascope' or 'freyja_standalone' or aquascope_dcipher."
    }
}

/*
========================================================================================
    THE END
========================================================================================
*/
