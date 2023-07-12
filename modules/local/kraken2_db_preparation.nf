process KRAKEN2_DB_PREPARATION {
    tag "${db.simpleName}"
    label 'process_low'

    conda "conda-forge::sed=4.7"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'ubuntu:20.04' }"

    input:
    path db

    output:
    tuple val("${db.simpleName}"), path("database/*.k2d"), emit: db
    path "versions.yml"                                  , emit: versions

    script:
    """
    mkdir database
    if [ -d "\$(realpath ${db})" ]; then 
        ln -s \$(realpath ${db})/*.k2d database/ 
    else
        mkdir db_tmp
        tar -xf "${db}" -C db_tmp
        mv `find db_tmp/ -name "*.k2d"` database/
    fi    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tar: \$(tar --version 2>&1 | sed -n 1p | sed 's/tar (GNU tar) //')
    END_VERSIONS
    """
}