process SIGNATURETOOLSLIB {
    label 'process_high'

    conda "r-base=4.2.3,r-optparse=1.7,umccr::r-signature.tools.lib=2.1.2,r-devtools=2.4.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker.io/biolancer/signaturetoolslib-docker:latest':
        'docker.io/biolancer/signaturetoolslib-docker:latest' }"
    containerOptions '-u $(id -u):$(id -g) --entrypoint=""'

    input:
    path input_matrix
    val  output_pattern

    output:
    path "*.json"                 , emit: json
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    signaturetoolslib.R \\
        --input_file  $input_matrix \\
        --output_name $output_pattern   \\
        $args   \\
        --threads $task.cpus    \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | head -n 1 | sed 's/^.*R version //; s/ .*\$//')
        signature.tools.lib: \$(Rscript -e "library(signature.tools.lib); cat(as.character(packageVersion('signature.tools.lib')))")
    END_VERSIONS
    """
}
