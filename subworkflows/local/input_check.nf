//
// Check input samplesheet and get read channels
//
def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

workflow INPUT_CHECK {
    main:
    if (hasExtension(params.input, "csv")) {
        ch_input_rows = Channel
            .from(file(params.input))
            .splitCsv(header: true)
            .map { row ->
                if (row.size() == 6) {
                    def id = row.id
                    def platform = row.platform
                    def fastq_1 = row.fastq_1 ? file(row.fastq_1, checkIfExists: true) : false
                    def fastq_2 = row.fastq_2 ? file(row.fastq_2, checkIfExists: true) : false
                    def lr = (platform == 'nanopore' || platform == 'pacbio') ? (row.lr ? file(row.lr, checkIfExists: true) : false) : false
                    def bam_file = (platform == 'iontorrent') ? (row.bam_file ? file(row.bam_file, checkIfExists: true) : false) : false
                    // Check if given combination is valid
                    if (!fastq_1) exit 1, "Invalid input samplesheet: short_reads_1 can not be empty."
                    if (!fastq_2 && lr) exit 1, "Invalid input samplesheet: invalid combination of single-end short reads and long reads provided! SPAdes does not support single-end data and thus hybrid assembly cannot be performed."
                    if (!fastq_2 && !params.single_end) exit 1, "Invalid input samplesheet: single-end short reads provided, but command line parameter `--single_end` is false. Note that either only single-end or only paired-end reads must provided."
                    if (fastq_2 && params.single_end) exit 1, "Invalid input samplesheet: paired-end short reads provided, but command line parameter `--single_end` is true. Note that either only single-end or only paired-end reads must provided."
                    
                    if ((platform == 'nanopore' || platform == 'pacbio') && !lr) {
                        exit 1, "Invalid input samplesheet: ${platform} platform requires long reads to be specified."
                    }

                    if (platform == 'iontorrent' && !fastq_1 && !bam_file) {
                        exit 1, "Invalid input samplesheet: IonTorrent platform requires either a BAM file or fastq_1 to be specified."
                    }

                    if (platform != 'iontorrent' && bam_file) {
                        exit 1, "Invalid input samplesheet: ${platform} platform does not require a BAM file."
                    }
                    
                    return [id, platform, fastq_1, fastq_2, lr, bam_file]
                } else {
                    exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 6."
                }
            }

        ch_raw_short_reads = ch_input_rows
            .filter { it[1] != 'iontorrent' }
            .map { [id, platform, fastq_1, fastq_2, lr, bam_file] ->
                def meta = [:]
                meta.id = id
                meta.single_end = params.single_end
                meta.platform = platform
                if (params.single_end) {
                    return [meta, [fastq_1]]
                } else {
                    return [meta, [fastq_1, fastq_2]]
                }
            }

        ch_raw_long_reads = ch_input_rows
            .filter { it[1] == 'nanopore' || it[1] == 'pacbio' }
            .map { [id, platform, fastq_1, fastq_2, lr, bam_file] ->
                if (lr) {
                    def meta = [:]
                    meta.id = id
                    meta.platform = platform
                    return [meta, lr]
                }
            }

        ch_raw_bam = ch_input_rows
            .filter { it[1] == 'iontorrent' }
            .map { [id, platform, fastq_1, fastq_2, lr, bam_file] ->
                if (bam_file) {
                    def meta = [:]
                    meta.id = id
                    meta.platform = platform
                    return [meta, bam_file]
                } else if (fastq_1) {
                    def meta = [:]
                    meta.id = id
                    meta.platform = platform
                    return [meta, [fastq_1]]
                }
            }
    } else {
         ch_raw_short_reads = Channel
            .fromFilePairs(params.input, size: params.single_end ? 1 : 2)
            .ifEmpty { exit 1, "Cannot find any reads matching: ${params.input}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --single_end on the command line." }
            .map { row ->
                def meta = [:]
                meta.id = row[0]
                meta.single_end = params.single_end
                meta.platform = row[1]
                if (params.single_end) {
                    return [meta, [row[2]]]
                } else {
                    return [meta, [row[2], row[3]]]
                }
            }
        ch_input_rows = Channel.empty()
        ch_raw_long_reads = Channel.empty()
        ch_raw_bam = Channel.empty()
    }

    // Ensure sample IDs are unique
    ch_input_rows
        .map { id, platform, fastq_1, fastq_2, lr, bam_file -> id}
        .toList()
        .map { ids ->
            if (ids.size() != ids.unique().size()) {
                exit 1, "ERROR: input samplesheet contains duplicated sample IDs!"
            }
        }

    emit:
    raw_short_reads = ch_raw_short_reads
    raw_long_reads = ch_raw_long_reads
    raw_bam = ch_raw_bam
}
