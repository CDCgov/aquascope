def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

workflow INPUT_BAM_CHECK {
    main:
    if (hasExtension(params.input, "csv")) {
        ch_input_rows = Channel
            .from(file(params.input))
            .splitCsv(header: true)
            .map { row ->
                if (row.size() == 2) {
                    def id = row.SNAME
                    def bam_file = row.BAMFILE ? file(row.BAMFILE, checkIfExists: true) : false

                    if (!bam_file) {
                        exit 1, "Invalid input samplesheet: BAM file must be specified."
                    }

                    if (!hasExtension(bam_file, ".bam")) {
                        exit 1, "Invalid input samplesheet: The bam_file column must end with .bam."
                    }

                    return [id, bam_file]
                } else {
                    exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 2."
                }  
            }

        ch_bam_files = ch_input_rows
            .map { id, bam_file ->
                def meta = [:]
                meta.id = id
                return [meta, bam_file]
            }
    } else {
        exit 1, "Input file must be a CSV."
    }

    // Ensure sample IDs are unique
    ch_input_rows
        .map { id, bam_file -> id }
        .toList()
        .map { ids -> if (ids.size() != ids.unique().size()) { exit 1, "ERROR: input samplesheet contains duplicated sample IDs!" } }

    emit:
    bam_files = ch_bam_files
}
