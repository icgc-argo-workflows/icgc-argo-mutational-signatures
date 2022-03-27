#!/usr/bin/env Rscript


##### Library
library(MutationalPatterns)
library(data.table)
library(optparse)

###
option_list = list(
  make_option(c("-i", "--input_file"), type="character", default=NULL,
              help="Matrix of counts", metavar="character"),
  make_option(c("-o", "--output_dir"), type="character", default=NULL,
              help="Output directory", metavar="character"),
  make_option(c("-r", "--reference"), type="character", default=NULL,
              help="Reference genome", metavar="character")
  
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$input_file) | is.null(opt$output_dir) | is.null(opt$reference) ){
  print_help(opt_parser)
  stop("Missing some input arguments... Exiting...", call.=FALSE)
}

### Set seed 
set.seed(164)

##### Input variables
DIR_RES <- opt$output_dir
INPUT_MAT <- opt$input_file 
GENOME <- opt$reference 

# Import variables
mut_mat_ICGC <- read.table(INPUT_MAT, row.names = 1, header=TRUE)
cosmic_signatures <- get_known_signatures(genome = GENOME)

# De novo signatures
nmf_res <- extract_signatures(mut_mat_ICGC, rank = 6)

# Error with the cutoff variable. It needs to be high for very similar signature profiles
nmf_res <- rename_nmf_signatures(nmf_res, cosmic_signatures, cutoff = 0.95)
# Save nmf results
fwrite(as.data.table(nmf_res$signatures, keep.rownames = "Type"), paste0(DIR_RES, "/Signatures_de_novo_pipe.txt") )

## Signature fitting
# Change to numerical if not
fit_res <- fit_to_signatures(mut_mat_ICGC,
                             cosmic_signatures )
## Save refitting results
fwrite(as.data.table(fit_res$contribution, keep.rownames = "Signature"), paste0(DIR_RES, "/Signatures_contribution_pipe.txt") )
