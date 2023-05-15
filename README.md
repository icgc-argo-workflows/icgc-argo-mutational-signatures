
# ICGC-ARGO Mutational Signature Workflow

This repository is an online versioned backup of the transfer of the icgc-argo mutational signature workflow from WFPM to NF-core standards. This repository is under heavy construction.

**TO-DO**: Transfer Nextflow-based pipeline into nf-core suite.


==================================================================================

                   ICGC-ARGO MUTATIONAL SIGNATURE WORKFLOW

==================================================================================

#### Documentation goes here

The ICGC-ARGO Mutational Signature Analysis workflow is a Nextflow based workflow manager which takes VCF files as input and generates mutational count matrices, signature exposures and error thresholds as output. The workflow uses openly available software for each module and each module can be run as a single instance. The workflow will be ported to adhere to the standards set by the [nf-core community](https://nf-co.re/). Further extension of the pipeline concerning pre- and postprocessing of the data is planned.

#### Authors & Collaborators

Lancelot Seillier @biolancer <lseillier@ukaachen.de>

Paula Stancl @ <e-mail-adresse>

Felix Beaudry @ <e-mail-adresse>

Linda Xiang @ <e-mail-adresse>

Arnab Chakrabatri @ <e-mail-adresse>

Taobo Hu @ <e-mail-adresse>

Sandesh Memane @ <e-mail-adresse>

Alvin Ng @ <e-mail-adresse>

Kjong Lehmann @ <e-mail-adresse>

...and more people?

----------------------------------------------------------------------------------

### Usage & Requirements

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10`)

2. **THIS STEP IS STILL A WIP! Docker and Singularity containers will be provided in the future, this step was left in the Usage description for completeness but should be skipped until further notice**. Install [`Docker`](https://docs.docker.com/engine/installation/) or [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), for full pipeline reproducibility _(you can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_.

3. Set up a [conda environment](https://docs.conda.io/en/latest/) and run the [Installdeps.sh script](bin/installdeps.sh) file. Until containerization is finished and tested, this should set up a conda environement named *icgcmutsig*, install all required dependencies and python packages and run the [reference installation script](bin/refinstall.py) for the count matrix generation.

4. To run the matrixgeneration of the counts, a one time installation of the GRCh38 reference genome is required. If step 3 did not finish successfully, you can install the reference genome by invoking the [refinstall python script](bin/refinstall.py).

```
python3 refinstall.py
```

5. To run the workflow using default settings, see the following use case example:

```
nextflow run main.nf -c nextflow.config --input path/to/vcf_folder --output output_filename --publishDir path/to/output_folder
```

**Required Parameters**:

```
--input: 	    Absolute path to the input folder containing VCF files.
--output:	    Naming convention for the output files; e.g. ${output}.json, ${output}.txt, etc.
--publishDir:   Output directory (as absolute path)
```

**Optional Parameters**:

```
--min:          Minimal amount of signatures to extract for the SigProfiler module; default: 1
--max:          Maximal amount of signatures to extract for the SigProfiler module; default: 10
--nmf:          NMF iterations/replicates to be performed by the SigProfiler module; default: 100
--cpus:         Cores which should be assigned to the workflow; default: 2
--mem:          RAM memory assigned to the workflow following Nextflow naming convention (e.g. "8.GB", "128.MB"); default: 8.GB
``` 

----------------------------------------------------------------------------------

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

## Pipeline summary

![workflow](/assets/workflow_diagramm.png)

1. Invoke matrixgenerator module to generate count matrices for SBS98, DBS78 and ID83 from the input VCF files
2. Invoke signaturetoolslib module to assign trinucleotide counts to the respective COSMIC signatures
3. Invoke the error thresholding module to generate error statistics based on Kullback-Leibler Divergence (KL), root mean square error (RSME), sum absolute of differences (SAD) and Hellinger Distance
4. Invoke the sigprofiler module to run the whole suite of tools described in the [SigProfilerExtractor](https://osf.io/t6j7u/wiki/home/) software package, including error estimation and default plots

Runtime statistics (e.g. Memory Usage, etc.) can be found in the generated ./runtime_inf folder in the workflow main folder.

### Credits

### Contributions and Support

- Matrixgenerator & Sigprofiler module: Lancelot Seillier
- Signaturetoolslib module: Paula Stancl
- Error Thresholding module: Felix Beaudry
- Visualization module: Taobo Hu
- Containerization: Sandesh Memane

For inquiries concerning the usage of the workflow or the ICGC project, please contact either:
- Linda Xiang
- Alvin Ng
- Kjong-Van Lehmann

### Citations

- The matrixgenerator module uses the SigProfiler matgen module of the SigProfiler suite: [Alexandrov et al.](10.1016/j.xgen.2022.100179)
- The signaturetoolslib module uses signaturetoolslib, an R library for mutational signature decomposition: [Degasperi et al.](10.1126/science.abl9283)
- The Error Thresholding module uses the R library packages *philentropy*, *Metrics* and *topicmodels*: [Citation of the packages]
