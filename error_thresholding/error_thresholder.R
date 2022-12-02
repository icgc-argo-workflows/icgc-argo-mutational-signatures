#!/usr/bin/Rscript

library(optparse)
library(jsonlite)
library(signature.tools.lib)

option_list = list(
  make_option(c("-j", "--input_json"), type="character", default=NULL,help="JSON from upstream", metavar="character"),
  make_option(c("-e", "--error_threshold"), type="character", default=NULL,help="JSON from upstream", metavar="character")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

##test data
#setwd('~/Documents/Github')
#input_json <- read_json('icgc-argo-mutational-signatures/signaturetoolslib/tests/expected/test_assignments.json')
#error_threshold <- 1000

unassigned_muts <- t(as.data.frame(input_json$unassigned_muts))

names(unassigned_muts[unassigned_muts > error_threshold,])
