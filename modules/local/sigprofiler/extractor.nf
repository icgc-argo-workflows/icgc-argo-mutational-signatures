process EXTRACTOR {
    label 'process_medium'

    conda "bioconda::sigmut=1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sigmut:1.0--hdfd78af_2':
        'biocontainers/sigmut:1.0--hdfd78af_2' }"

    input:
    path input
    val  output_pattern
    val  filetype

    output:
    path "output"                   , emit: sigprofiler_output
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    sigprofiler.py \\
        --filetype $filetype \\
        --input $input \\
        --output_pattern $output_pattern \\
        $args \\
        --threads $task.cpus    \\
        2> $workDir/sigprofiler.error.log \\
        1> $workDir/sigprofiler.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
