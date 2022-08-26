#!/usr/bin/Rscript

# Library
library(signature.tools.lib)
library("optparse")

#####INPUT

###
option_list = list(
  make_option(c("-i", "--input_file"), type="character", default=NULL,
              help="Matrix of counts", metavar="character"),
  make_option(c("-o", "--output_dir"), type="character", default=NULL,
              help="Output directory", metavar="character")
  
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$input_file) | is.null(opt$output_dir) ){
  print_help(opt_parser)
  stop("Missing some input arguments... Exiting...", call.=FALSE)
}

### Set seed 
set.seed(164)

##### Input variables
DIR_RES <- opt$output_dir
INPUT_MAT <- opt$input_file

# Import variables
mut_mat_ICGC <- read.table(INPUT_MAT, row.names = 1, header=TRUE)

## Function for extracting signatures
extractSignatures <- function(input_matrix, sig_matrix) {
  
  subs_fit_res <- signature.tools.lib::Fit(catalogues = input_matrix,
                                           exposureFilterType = "giniScaledThreshold",
                                           signatures = sig_matrix,
                                           useBootstrap = TRUE,
                                           nboot = 100,
                                           nparallel = 6 )
  # Save 
  #snv_exp <- subs_fit_res$E_median_filtered
  # Return
  return(subs_fit_res)
}


# Extract the signatures
sign_res <- extractSignatures(mut_mat_ICGC, COSMIC30_subs_signatures)

### Save output as JSON
fitToJSON(sign_res,
          paste0(DIR_RES, "/export_signatures.json") )


                       