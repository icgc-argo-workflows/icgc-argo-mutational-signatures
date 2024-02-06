process ASSESSMENT {
    label 'process_single'

    conda "conda-forge::python=3.8.3 conda-forge::pandas=2.0.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-371b28410c3e53c7f9010677515b1b0eb3764999:0267f53936b6c04b051e07833c218f1fdd2a7cac-0' :
        'biocontainers/mulled-v2-371b28410c3e53c7f9010677515b1b0eb3764999:0267f53936b6c04b051e07833c218f1fdd2a7cac-0' }" /// container taken from cio-abcd-vip

    input:
    path input_to_reorder

    output:
    path "SBS96_reordered_forCOSMIC.txt"            , emit: reordered_cosmic
    path "SBS96_reordered_forSIGTOOLS.txt"          , emit: reordered_sigtool
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    assessment.py \\
        --input $input_to_reorder \\
        $args


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        pandas: \$(python -c "import pandas; print(pandas.__version__)")
    END_VERSIONS
    """
}
