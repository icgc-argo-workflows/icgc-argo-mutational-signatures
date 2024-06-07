process ERRORTRESHOLDING {
    label 'process_low'
    errorStrategy 'ignore'

    conda "r-base=4.2.3,r-dplyr=1.1.3,r-optparse=1.7,r-devtools=2.4.5,r-topicmodels=0.2_7,r-philentropy=0.7.0,r-metrics=0.1.4,r-jsonlite=1.8.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biocontainers/mulled-v2-e532af651681c2ba0bc6a8a0bd8f7b7dafad9383:0'   :
        'biocontainers/mulled-v2-e532af651681c2ba0bc6a8a0bd8f7b7dafad9383:0' }"

    input:
    path    json_input
    path    input_matrix
    val     output_pattern

    output:
    path "*.json"                   , emit: error_values
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    error_thresholder.R \\
        --input $json_input \\
        --signature_matrix $input_matrix \\
        --output $output_pattern \\
        $args \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | head -n 1 | sed 's/^.*R version //; s/ .*\$//')
        topicmodels: \$(Rscript -e "library(topicmodels); cat(as.character(packageVersion('topicmodels')))")
        Metrics: \$(Rscript -e "library(Metrics); cat(as.character(packageVersion('Metrics')))")
        philentropy: \$(Rscript -e "library(philentropy); cat(as.character(packageVersion('philentropy')))")
    END_VERSIONS
    """
}
