#!/usr/bin/Rscript

library(optparse)
library(jsonlite)
library(signature.tools.lib)

library(philentropy)
library(statip)
library(Metrics)

option_list = list(
  make_option(c("-j", "--input_json"), type="character", default=NULL,help="JSON from upstream", metavar="character"),
 # make_option(c("-e", "--error_threshold"), type="character", default=NULL,help="JSON from upstream", metavar="character"),
  make_option(c("-s", "--signature_matrix"), type="character", default=NULL,help="matrix from which the signatures were calculated", metavar="character")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

##test data
setwd('~/Documents/Github')
input_json <- read_json('icgc-argo-mutational-signatures/signaturetoolslib/tests/expected/test_assignments.json')
signature_matrix <- 
#error_threshold <- 1000

catalog <- input_json$catalogues[[1]]

exposures <- input_json$exposures[[1]]
predicted <- exposures * signature_matrix

## Calculate Differences

### Kullback-Leibler Divergence // beta divergence
kl_data <- philentropy::KL(x = cbind.data.frame(catalog,predicted),est.prob = TRUE)

### Hellinger Distance
hellinger_data <- statip::hellinger(catalog,predicted)

### root mean square error (RMSE)
rmse_data <- Metrics::rmse(catalog,predicted)

### Normal error, sum Absolute of differences (SAD)
data.frame(catalog,predicted) %>% mutate(SAD = abs(catalog) + abs(predicted))





