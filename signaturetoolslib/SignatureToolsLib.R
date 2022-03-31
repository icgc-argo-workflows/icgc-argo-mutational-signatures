#!/usr/bin/Rscript

# Library
library(data.table)
library(signature.tools.lib)
library(magrittr)
library("optparse")

#####INPUT

###
option_list = list(
  make_option(c("-i", "--input_file"), type="character", default=NULL,
              help="Matrix of counts", metavar="character"),
  make_option(c("-o", "--output_dir"), type="character", default=NULL,
              help="Output directory", metavar="character"),
  make_option(c("-t", "--tissue"), type="character", default=NULL,
              help="Tissue type", metavar="character")
  
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$input_file) | is.null(opt$output_dir) | is.null(opt$tissue) ){
  print_help(opt_parser)
  stop("Missing some input arguments... Exiting...", call.=FALSE)
}

### Set seed 
set.seed(164)

##### Input variables
DIR_RES <- opt$output_dir
INPUT_MAT <- opt$input_file 
TISSUE <- opt$tissue 

# Import variables
mut_mat_ICGC <- read.table(INPUT_MAT, row.names = 1, header=TRUE)


## Function for extracting signatures
extractSignatures <- function(input_matrix, sig_matrix) {
  
  subs_fit_res <- SignatureFit_withBootstrap_Analysis(outdir = paste0(DIR_RES, "/"),
                                    cat = input_matrix,
                                    signature_data_matrix = sig_matrix,
                                    type_of_mutations = "subs",
                                    nboot = 100,
                                    nparallel = 8)
  # Save 
  snv_exp <- subs_fit_res$E_median_filtered
  # Return
  return(snv_exp)
  
}

## Organ specific or not extraction of mutational signatures
if (TISSUE != "none" ) {
  # Organ specific signatures
  cosmic_signatures <- getOrganSignatures(TISSUE)
  # Extract signatures and convert them to reference signatures
  sign_res <- extractSignatures(mut_mat_ICGC, cosmic_signatures) %>% 
    convertExposuresFromOrganToRefSigs
}
if (TISSUE == "none") {
  # COSMIC signatures
  cosmic_signatures <- COSMIC30_subs_signatures
  # Extract the signatures
  sign_res <- extractSignatures(mut_mat_ICGC, cosmic_signatures)
}

                       