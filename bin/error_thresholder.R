#!/usr/bin/Rscript

library(optparse)
library(jsonlite)
library(signature.tools.lib)

library(philentropy)
library(Metrics)
library(dplyr)
library(topicmodels)

#### INPUT ####

option_list = list(
    make_option(c("-i", "--input"), type="character", default=NULL,help="Input JSON from upstream analysis process", metavar="character"),
    make_option(c("-s", "--signature_matrix"), type="character", default=NULL,help="Input Count Matrix from which the signature assignments were calculated", metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,help="Output filename pattern", metavar="character")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

input_location <- opt$input
signature_matrix_location <- opt$signature_matrix
output_name <- opt$output

##import data
signature_matrix <-  read.table(signature_matrix_location,header = T)
input_json <- read_json(input_location) #signature.tools.lib outputs json

#reformat inputs
catalog <- unlist(input_json$catalogues[[1]])
exposures <- as.data.frame(input_json$exposures[[1]])

#predict from exposures and signature matrix
predicted_mat <- t(exposures) * signature_matrix[,-1]
predicted_sum <- rowSums(predicted_mat)
names(predicted_sum) <- signature_matrix[,1]

#### CALCULATE ####

### Kullback-Leibler Divergence // beta divergence
kl_data <- philentropy::KL(x = rbind(catalog/sum(catalog),predicted_sum/sum(predicted_sum)))

### root mean square error (RMSE)
rmse_data <- Metrics::rmse(catalog,predicted_sum)

### Normal error, sum Absolute of differences (SAD)
SAD_table <- data.frame(catalog,predicted_sum) %>%
                            mutate(SAD = abs(catalog) + abs(predicted_sum))
SAD_data  <- sum(SAD_table$SAD)

### Hellinger Distance
hellinger_data <- topicmodels::distHellinger(t(as.data.frame(catalog)),t(as.data.frame(predicted_sum)))

#### OUTPUT ####

#stick all the results together
all.results <- list(kl_data[[1]],rmse_data,SAD_data,unlist(hellinger_data[1]))
names(all.results) <- c("KL","RMSE","SAD","Hellinger")

#conver to JSON and write
ListJSON <- jsonlite::toJSON(all.results,pretty=TRUE,auto_unbox=TRUE)

write(ListJSON,file = paste(output_name, "_errors.json",sep=""))

