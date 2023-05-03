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
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 4
params.mem = 8  // GB

params.publish_dir = ""  // set to empty string will disable publishDir

// tool specific parmas go here, add / change as needed

params.input = ""
params.output = "sigpro_tmp"  // output file name pattern
params.min = 1    // minimal number of signatures to assign count data to, default is [1]
params.max = 10   // maximal number of signatures to assign count data to, default is [10]
params.nmf = 100  // number of NMF replicates to run, default is [100]


process sigprofiler {
//  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}" // invokes "Ambiguous method overloading for method org.codehaus.groovy.runtime.GStringImpl#getAt." error -- maybe rewrite everything?
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path params.input

  output:  // output, make update as needed
    path params.output,                                  emit: sigpro_out

  script:
    // add and initialize variables here as needed
    """
    python ../../../modules/local/sigprofiler/sigprofiler_ICGC.py ${params.input} ${params.output} ${params.min} ${params.max} ${params.nmf} ${params.cpus}
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx

workflow {
  sigprofiler(
    file(params.input_file)
  )
}