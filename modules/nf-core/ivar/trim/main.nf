process IVAR_TRIM {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ivar:1.4.3--h43eeafb_0' :
        'biocontainers/ivar:1.4.3--h43eeafb_0' }"

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
    def bedfile = "${meta.bedfile}"
    def bedfile_basename = "${bedfile}".tokenize('/').last()

    """
    
    if [[ ${bedfile} == https://* ]]; then
        wget -O $bedfile_basename $bedfile
    elif [[ -f ${bedfile} ]]; then
        # Local file, no need to download
        cp ${bedfile} ${bedfile_basename}
    else
        echo "Invalid bedfile: ${bedfile}"
        exit 1
    fi

    ivar trim \\
        $args \\
        -i $bam \\
        -b ${bedfile_basename} \\
        -p ${prefix} \\
        > ${prefix}.ivar.log

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            ivar: \$(echo \$(ivar version 2>&1) | sed 's/^.*iVar version //; s/ .*\$//')
        END_VERSIONS
        """
}
