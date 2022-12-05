#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
==================================================================================
                   ICGC-ARGO MUTATIONAL SIGNATURE WORKFLOW
==================================================================================
#### Documentation goes here

#### Authors
Paula Stancl @ <e-mail-adresse>
Lancelot Seillier @biolancer <lseillier@ukaachen.de>
Felix Beaudry @ <e-mail-adresse>
Linda Xiang @ <e-mail-adresse>
Arnab Chakrabatri @ <e-mail-adresse>
Taobo Hu @ <e-mail-adresse>
Alvin Ng @ <e-mail-adresse>
Kjong Lehmann @ <e-mail-adresse>
...and more people?

----------------------------------------------------------------------------------

Required Parameters:


General Parameters:


----------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PARAMETER Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { ICGCMUTSIGWORKFLOW } from './workflows/icgc_mutational_signature_workflow'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    ICGCMUTSIGWORKFLOW ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
