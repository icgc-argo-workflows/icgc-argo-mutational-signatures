#!/usr/bin/Rscript

### Initial script written by Paula Stancl
### Adapted for nf-core workflow by Lancelot Seillier

library(signature.tools.lib)
library("optparse")

option_list = list(
    make_option(c("-i", "--input_file"), type="character", default=NULL,
                help="Matrix of counts", metavar="character"),
    make_option(c("-o", "--output_name"), type="character", default=NULL,
                help="Output file", metavar="character"),
    make_option(c("-n", "--boots"), type="integer", default=NULL,
                help="Number of bootstrapping iterations", metavar="integer"),
    make_option(c("-t", "--threads"), type="integer", default=NULL,
                help="Threads used for assignment", metavar="integer")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$input_file)){
    print_help(opt_parser)
    stop("Missing some input arguments... Exiting...", call.=FALSE)
}

## Set seed used to match expected output
set.seed(164)

## Input variables
INPUT_MAT <- opt$input_file
OUT_NAME <- opt$output_name
BOOTS <- opt$boots
THREADS <- opt$threads

## Import matrix of counts
mut_mat_ICGC <- read.table(INPUT_MAT, row.names = 1, header=TRUE)

## Function for signature attribution
assignSignatures <- function(input_matrix, sig_matrix, boots_n, threads) {

## use Fit function, FitMS is still undergoing testing
## LS: Potentially extend for non-COSMIC signatures or organ-specific
    subs_fit_res <- signature.tools.lib::Fit(catalogues = input_matrix,
                                            exposureFilterType = "giniScaledThreshold",
                                            signatures = sig_matrix,
                                            useBootstrap = TRUE,
                                            nboot = boots_n,
                                            nparallel = threads)
    return(subs_fit_res)
}

## Assign the signatures
## Currently testing with COSMIC 30 signatures (To update)
sign_res <- assignSignatures(mut_mat_ICGC, COSMIC30_subs_signatures, BOOTS, THREADS)

### Save output as JSON
signature.tools.lib::fitToJSON(sign_res,paste0(OUT_NAME, ".json"))
