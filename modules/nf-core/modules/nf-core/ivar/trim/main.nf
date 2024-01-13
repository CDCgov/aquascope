process IVAR_TRIM {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::ivar=1.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ivar:1.4--h6b7c446_1' :
        'quay.io/biocontainers/ivar:1.4--h6b7c446_1' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path('*.log'), emit: log
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def platform = "${meta.platform}"
    def bedfile = platform == 'nanopore' || platform == 'pacbio' ? "${params.long_bedfile}" : "${params.short_bedfile}"
    
    def ivar_trim_command =
    """
    ivar trim \\
        $args \\
        -i $bam \\
        -b ${bedfile} \\
        -p ${prefix} \\
        > ${prefix}.ivar.log """
    """
    ${ivar_trim_command}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ivar: \$(echo \$(ivar version 2>&1) | sed 's/^.*iVar version //; s/ .*\$//')
    END_VERSIONS
    """
}