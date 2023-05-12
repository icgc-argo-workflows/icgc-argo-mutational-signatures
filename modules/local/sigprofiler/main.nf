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
params.output =                     ""              // output file name pattern
params.min =                        ""              // minimal number of signatures to assign count data to, default is [1]
params.max =                        ""              // maximal number of signatures to assign count data to, default is [10]
params.nmf =                        ""              // number of NMF replicates to run, default is [100]


process SIGPROFILER {

  publishDir "${params.publishDir}/${task.process.replaceAll(':', '_')}", mode: "copy"

  cpus params.cpus
  memory "${params.mem} GB"

  input:
    path params.input

  output:
    path params.output,     emit: sigpro_out

  script:
    
    """
    python ../../../modules/local/sigprofiler/sigprofiler_ICGC.py ${params.input} ${params.output} ${params.min} ${params.max} ${params.nmf} ${params.cpus}
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx

workflow {
  SIGPROFILER(
    file(params.input_file)
  )
}
