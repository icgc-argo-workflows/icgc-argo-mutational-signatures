#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
name = 'Reference Genome Installation helper routine'
version = '0.1.0'  // package version

process refinstall {

    """
    #!/usr/bin/env python3
    
    from SigProfilerMatrixGenerator import install as genInstall

    genInstall.install('GRCh38', rsync=False)
    """
}

workflow {
    refinstall()
}
