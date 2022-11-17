#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
name = 'icgc-mutational-signature-workflow'
version = '0.1.0'  // package version

/*
==================================================================================
                   ICGC-ARGO MUTATIONAL SIGNATURE WORKFLOW
==================================================================================
#### Documentation goes here

#### Authors
Paula Stancl @ <e-mail-adresse>
Lancelot Seillier @biolancer <lseillier@ukaachen.de>

----------------------------------------------------------------------------------

Required Parameters:
--input_file: Absolute Path to a MAF file following ICGC convention

General Parameters:
--cpus: Cores assigned to the workflow [default: 2]
--mem: Memory assigned to the workflow [default: 8 GB]

----------------------------------------------------------------------------------
*/

// Define General Parameters
params.container = ""
params.container_registry = ""
params.container_version = ""
params.cpus = 2
params.mem = 8  // GB
params.publish_dir = ""  // set to empty string will disable publishDir

// tool specific parmas go here, add / change as needed ### TODO
params.input_file = ""
params.cleanup = true


// include packages used in the worklfow - adapt to new versions as needed
include { signaturetoolslib } from './wfpr_modules/github.com/icgc-argo-workflows/icgc-argo-mutational-signatures/signaturetoolslib@0.1.1/main.nf' params([*:params, 'cleanup': false])
include { matrixgenerator } from './wfpr_modules/github.com/icgc-argo-workflows/icgc-argo-mutational-signatures/matrixgenerator@0.1.0/main.nf' params([*:params, 'cleanup': false])


// please update workflow code as needed
workflow IcgcMutationalSignatureWorkflow {
  take:  // update as needed
    input_file


  main:  // update as needed
    matrixgenerator(params.input_file)
    signaturetoolslib(matrixgenerator.out.output_file)


  emit:  // update as needed
    output_file = signaturetoolslib.out.output_file

}


// this provides an entry point for this main script, so it can be run directly without clone the repo

workflow {
  IcgcMutationalSignatureWorkflow(
    params.input_file
  )
}
