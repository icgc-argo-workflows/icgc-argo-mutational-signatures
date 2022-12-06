
# ICGC-ARGO Mutational Signature Workflow

This repository is an online versioned backup of the transfer of the icgc-argo mutational signature workflow from WFPM to NF-core standards. This repository is under heavy construction.


==================================================================================
                   ICGC-ARGO MUTATIONAL SIGNATURE WORKFLOW
==================================================================================
#### Documentation goes here

#### Authors
Lancelot Seillier @biolancer <lseillier@ukaachen.de>
Paula Stancl @ <e-mail-adresse>
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

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

## Pipeline summary

![workflow](/assets/workflow_diagramm.png)

1. Invoke matrixgenerator module to generate trinucleotide matrix from ICGC-MAF files
2. Invoke signaturetoolslib module to assign trinucleotide counts to the respective COSMIC signatures
3. Invoke ... to generate a 

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10`)

2. Install [`Docker`](https://docs.docker.com/engine/installation/) or [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), for full pipeline reproducibility _(you can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_.

3. Download the pipeline and test it on a minimal dataset with a single command:

   ```bash
   nextflow run nf-core/icgc_mutational_signature_workflow -profile test,YOURPROFILE --outdir <OUTDIR>
   ```

   Note that some form of configuration will be needed so that Nextflow knows how to fetch the required software. This is usually done in the form of a config profile (`YOURPROFILE` in the example command above). You can chain multiple config profiles in a comma-separated string.

   > - The pipeline comes with config profiles called `docker`, `singularity`, `podman`, `shifter`, `charliecloud` and `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,docker`.
   > - Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.
   > - If you are using `singularity`, please use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to download images first, before running the pipeline. Setting the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
   > - If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

4. Start running your own analysis!

   <!-- TODO nf-core: Update the example "typical command" below used to run the pipeline -->

   ```bash
   nextflow run nf-core/icgc_mutational_signature_workflow --input samplesheet.csv --outdir <OUTDIR> --genome GRCh37 -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
   ```

## Documentation

The nf-core/icgc_mutational_signature_workflow pipeline comes with documentation about the pipeline [usage](https://nf-co.re/icgc_mutational_signature_workflow/usage), [parameters](https://nf-co.re/icgc_mutational_signature_workflow/parameters) and [output](https://nf-co.re/icgc_mutational_signature_workflow/output).

## Credits



## Contributions and Support

Workflow maintenance and matrixgenerator module: Lancelot Seillier
Signaturetoolslib module: Paula Stancl
Assignment error module: Felix Beaudry
Visualization module: Taobo Hu

For inquiries concerning the usage of the workflow or the ICGC project, please contact either:
Linda Xiang
Alvin Ng
Kjong-Van Lehmann

## Citations

- The matrixgenerator module uses the SigProfiler matgen module of the SigProfiler suite: [Citation of Alexandrov et al.]
- The signaturetoolslib module uses signaturetoolslib, an R library for mutational signature decomposition: [Citation of SigToolsLib author]
