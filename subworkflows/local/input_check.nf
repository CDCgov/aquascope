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
                if (row.size() == 7) {
                    def id = row.sample
                    def platform = row.platform
                    def fastq_1 = row.fastq_1 ? file(row.fastq_1, checkIfExists: true) : false
                    def fastq_2 = row.fastq_2 ? file(row.fastq_2, checkIfExists: true) : false
                    def lr = (platform == 'nanopore' || platform == 'pacbio') ? (row.lr ? file(row.lr, checkIfExists: true) : false) : false
                    def bam_file = (platform == 'iontorrent') ? (row.bam_file ? file(row.bam_file, checkIfExists: true) : false) : false
                    def bedfile = row.bedfile ? row.bedfile.toString() : null
                    print "Bedfile being used: ${id} : ${bedfile}"

                    if ((platform == 'nanopore' || platform == 'pacbio') && !lr) {
                        exit 1, "Invalid input samplesheet: ${platform} platform requires long reads to be specified."
                    }
                    if ((platform == 'iontorrent') && !bam_file) {
                        exit 1, "Invalid input samplesheet: IonTorrent platform requires either a BAM file or short_reads_1 to be specified."
                    }
                    if (platform in ['illumina', 'nanopore', 'pacbio'] && !bedfile) {
                        exit 1, "Invalid input samplesheet: ${platform} platform requires a bedfile to be specified."
                    }
                    return [id, platform, fastq_1, fastq_2, lr, bam_file, bedfile]
                } else {
                    exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 7."
                }  
            }
        ch_raw_short_reads = ch_input_rows.filter { it[1] == 'illumina' }
            .map { id, platform, fastq_1, fastq_2, lr, bam_file, bedfile ->
                def meta = [:]
                meta.id = id
                meta.platform = platform
                meta.single_end = !fastq_2
                meta.bedfile = bedfile
                if (fastq_2) {
                    return [meta, [fastq_1, fastq_2]]
                } else {
                    return [ meta, [fastq_1]]
                }
            }
        ch_raw_long_reads = ch_input_rows.filter { it[1] == 'nanopore' || it[1] == 'pacbio' }
            .map { id, platform, fastq_1, fastq_2, lr, bam_file, bedfile ->
                if (lr) {
                    def meta = [:]
                    meta.id = id
                    meta.platform = platform
                    meta.bedfile = bedfile
                    return [ meta, lr]
                }
            }
        ch_raw_bam = ch_input_rows.filter { it[1] == 'iontorrent' }
            .map { id, platform, fastq_1, fastq_2, lr, bam_file, bedfile ->
                if (bam_file) {
                    def meta = [:]
                    meta.id = id
                    meta.platform = platform
                    return [meta, bam_file]
                } else {
                    def meta = [:]
                    meta.id = id
                    meta.platform = platform
                    return [meta, null]  
                }
            }
    } else {
        ch_raw_short_reads = Channel.fromFilePairs(params.input, size: 2)
            .ifEmpty { exit 1, "Cannot find any reads matching: ${params.input}. Please make sure the correct combination of short_reads_1 and short_reads_2 is provided for Illumina data." }
            .map { row ->
                def meta = [:]
                meta.id = row[0]
                meta.platform = 'illumina'
                meta.bedfile = bedfile
                return [meta, row[1..row.size()]]
            }
        ch_input_rows = Channel.empty()
        ch_raw_long_reads = Channel.empty()
        ch_raw_bam = Channel.empty()
    }

     // Ensure sample IDs are unique
    ch_input_rows
        .map { id, platform, fastq_1, fastq_2, lr, bam_file, bedfile -> id }
        .toList()
        .map { ids -> if (ids.size() != ids.unique().size()) { exit 1, "ERROR: input samplesheet contains duplicated sample IDs!" } }

    emit:
    raw_short_reads = ch_raw_short_reads
    raw_long_reads = ch_raw_long_reads
    raw_bam = ch_raw_bam

}
