process FREYJA_VARIANTS {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::freyja=1.5.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/freyja:1.5.0--pyhdfd78af_0':
        'quay.io/biocontainers/freyja:1.5.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(bam)
    path fasta

    output:
    tuple val(meta), path("*.variants.tsv"), emit: variants
    tuple val(meta), path("*.depth.tsv"), emit: depths
    path "versions.yml"                                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    freyja \\
        variants \\
        $args \\
        --ref $fasta \\
        --variants ${prefix}.variants.tsv \\
        --depths ${prefix}.depth.tsv \\
        $bam

    awk -F'\\t' 'BEGIN {OFS = FS} 
    {
        if (\$2 >= 1 && \$2 <= 265) {
            \$15 = "five_prime_UTR"
        } else if (\$2 >= 266 && \$2 <= 21555) {
            \$15 = "orf1ab:cds-QHD43415.1"
        } else if (\$2 >= 21563 && \$2 <= 25384) {
            \$15 = "S:cds-QHD43416.1"
        } else if (\$2 >= 25393 && \$2 <= 26220) {
            \$15 = "ORF3a:cds-QHD43417.1"
        } else if (\$2 >= 26245 && \$2 <= 26472) {
            \$15 = "E:cds-QHD43418.1"
        } else if (\$2 >= 26523 && \$2 <= 27191) {
            \$15 = "M:cds-QHD43419.1"
        } else if (\$2 >= 27202 && \$2 <= 27387) {
            \$15 = "ORF6:cds-QHD43420.1"
        } else if (\$2 >= 27394 && \$2 <= 27759) {
            \$15 = "ORF7a:cds-QHD43421.1"
        } else if (\$2 >= 27894 && \$2 <= 28259) {
            \$15 = "ORF8:cds-QHD43422.1"
        } else if (\$2 >= 28274 && \$2 <= 29533) {
            \$15 = "N:cds-QHD43423.2"
        } else if (\$2 >= 29558 && \$2 <= 29674) {
            \$15 = "ORF10:cds-QHI42199.1"
        } else if (\$2 >= 29675 && \$2 <= 29903) {
            \$15 = "three_prime_UTR"
        }
        print \$0
    }' ${prefix}.variants.tsv > ${prefix}.annotated.variants.tsv

    mv ${prefix}.annotated.variants.tsv ${prefix}.variants.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freyja: \$(echo \$(freyja --version 2>&1) | sed 's/^.*version //' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.variants.tsv
    touch ${prefix}.depth.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freyja: \$(echo \$(freyja --version 2>&1) | sed 's/^.*version //' )
    END_VERSIONS
    """
}