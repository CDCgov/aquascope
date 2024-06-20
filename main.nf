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
WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

// Include the workflows from their respective files
include { AQUASCOPE         } from './workflows/aquascope'
include { FREYJA_STANDALONE } from './workflows/freyja_standalone'

//
// WORKFLOW: Run main nf-core/aquascope analysis pipeline
//
workflow NFCORE_AQUASCOPE {
    AQUASCOPE()
}

//
// WORKFLOW: Run Freyja standalone analysis
//
workflow NFCORE_FREYJA_STANDALONE {
    FREYJA_STANDALONE()
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
    } else {
        error "Unknown workflow specified: ${params.workflow}. Valid options are 'aquascope' or 'freyja_standalone'."
    }
}

/*
========================================================================================
    THE END
========================================================================================
*/
