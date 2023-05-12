#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
version = '0.2.0'

/*
  Copyright (c) 2021, ICGC ARGO

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    [Lancelot Seillier]
*/


// universal params go here
////

params.container_registry =         ""
params.container_version =          ""
params.container =                  ""

params.cpus =                       ""
params.mem =                        ""  // GB
params.publishDir =                 ""  // set to empty string will disable publishDir


// tool specific parmas go here, add / change as needed
////

params.input =                      ""
params.output =                     ""  // output file name pattern


process MATRIXGENERATOR {

  publishDir "${params.publishDir}/${task.process.replaceAll(':', '_')}", mode: "copy"

  cpus params.cpus
  memory "${params.mem} GB"

  input:
    path params.input

  output:
    path "Trinucleotide_matrix_${params.output}_SBS96.txt",     emit: output_SBS
    path "Trinucleotide_matrix_${params.output}_DBS78.txt",     emit: output_DBS
    path "Trinucleotide_matrix_${params.output}_ID83.txt",      emit: output_ID

  script:

    """
    python ../../../modules/local/matrixgenerator/ICGC_allSigs_matGen.py ${params.input} ${params.output}
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx

workflow {
  MATRIXGENERATOR(
    file(params.input)
  )
}
