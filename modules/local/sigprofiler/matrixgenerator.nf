process MATRIXGENERATOR {
    label 'process_low'

    conda "bioconda::sigmut=1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'quay.io/superjw/docker-sigprofiler':
        'quay.io/superjw/docker-sigprofiler' }" // needs his own container

    input:
    path input
    val  output_pattern
    val  filetype


    output:
    path "Trinucleotide_matrix_${params.output_pattern}_SBS96.txt",     emit: output_SBS
    path "Trinucleotide_matrix_${params.output_pattern}_DBS78.txt",     emit: output_DBS
    path "Trinucleotide_matrix_${params.output_pattern}_ID83.txt" ,     emit: output_ID
    val("process_complete")                                       ,     emit: matgen_finished
    path "versions.yml"                                           ,     emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    matrixgenerator.py \\
        --filetype $filetype \\
        --input $input \\
        --output_pattern $output_pattern \\
        $args \\
        2> $workDir/matrixgenerator.error.log \\
        1> $workDir/matrixgenerator.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        SigProfilerMatrixGenerator: \$(python -c "import SigProfilerMatrixGenerator; print(SigProfilerMatrixGenerator.__version__)")
    END_VERSIONS
    """
}
