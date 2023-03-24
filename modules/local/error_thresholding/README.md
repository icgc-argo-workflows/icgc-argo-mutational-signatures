# Error Thresholding module

The module calculates the Kullback-Leibler Divergence (KL), the root-mean square error (RMSE), sum of absolute differences (SAD) and Hellinger Distance of the input matrix and signature exposure assignments.

Extend for additional information. :)

## Package development

Error Thresholding is the third step in the Mutational Signatures workflow, building from the concepts of [Alexandrov et al. 2013](https://www.cell.com/cell-reports/fulltext/S2211-1247(12)00433-0?_returnURL=https%3A%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS2211124712004330%3Fshowall%3Dtrue).  

This version has been rewritten to suit nf-core standards, see [https://nf-co.re/developers/adding_pipelines#create-a-pipeline-from-the-template] for more details

## Usage

### Run the package directly

How to use this package directly without any other stuff attached to it.


```
nextflow run main.nf --input path/to/output.json --signature_matrix path/to/matrix
```
