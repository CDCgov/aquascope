process MINIMAP2_ALIGN {
    tag "$meta.id"
    label 'process_medium'

    // Note: the versions here need to match the versions used in the mulled container below and minimap2/index
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:3161f532a5ea6f1dec9be5667c9efc2afdac6104-0' :
        'biocontainers/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:3161f532a5ea6f1dec9be5667c9efc2afdac6104-0' }"

    input:
    tuple val(meta), path(reads)
    path reference
    val bam_format 
    val cigar_paf_format
    val cigar_bam 

    output:
    tuple val(meta), path("*.paf"), optional: true, emit: paf
    tuple val(meta), path("*.bam"), optional: true, emit: bam
    tuple val(meta), path("*.bai"), optional: true, emit: bai
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bam_output = bam_format ? "-a | samtools sort | samtools view -@ ${task.cpus} -b -h -o ${prefix}.bam" : "-o ${prefix}.paf"
    def cigar_paf = cigar_paf_format && !bam_format ? "-c" : ''
    def set_cigar_bam = cigar_bam && bam_format ? "-L" : ''
    def platform = "${meta.platform}"
    def minimap2_args = ''

    if (platform == 'illumina' || platform == 'iontorrent') {
        minimap2_args = "-x sr"
    } else if (platform == 'nanopore') {
        minimap2_args = "-x map-ont --secondary=no --sam-hit-only"
    } else if (platform == 'pacbio') {
        minimap2_args = "-x map-hifi" //Continuous reads shorter than 20kb
    } else {
        error "Invalid platform argument: ${platform}"
    }
    def alignment_command = 
    """ minimap2 \\
        $minimap2_args \\
        -t $task.cpus \\
        ${reference ?: reads} \\
        ${reads} \\
        $cigar_paf \\
        $set_cigar_bam \\
        $bam_output """
    """
    ${alignment_command} 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$(minimap2 --version 2>&1)
    END_VERSIONS
    """
}
