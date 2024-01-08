process EXTRACTOR {
    label 'process_high'

    conda "bioconda::sigmut=1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'quay.io/superjw/docker-sigprofiler':
        'quay.io/superjw/docker-sigprofiler' }"

    input:
    path input
    val  output_pattern
    val  filetype
    val  matgen_finished

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
        SigProfilerExtractor: \$(python -c "import SigProfilerExtractor; print(SigProfilerExtractor.__version__)")
    END_VERSIONS
    """
}
