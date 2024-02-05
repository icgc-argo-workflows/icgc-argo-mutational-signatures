process ASSIGNMENT {
    label 'process_high'

    conda "bioconda::sigmut=1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker.io/fauzul/sigprofiler:1.0':
        'docker.io/fauzul/sigprofiler:1.0' }"

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
        2> $workDir/sigprofiler.error.log \\
        1> $workDir/sigprofiler.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        SigProfilerAssignment: \$(python -c "import SigProfilerAssignment; print(SigProfilerAssignment.__version__)")
    END_VERSIONS
    """
}
