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
    def bedfile = "${meta.bedfile}"
    def bedfile_basename = "${bedfile}".tokenize('/').last()
    def args2 = ""
    
    // Check sequencing platform and set custom parameters accordingly
    if (platform == 'nanopore') {
        args2 = "-e -q 15 -s 4"
    } else if (platform == 'illumina' || platform == 'iontorrent') {
        args2 = "-q 20"
    }

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
        $args2 \\
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
