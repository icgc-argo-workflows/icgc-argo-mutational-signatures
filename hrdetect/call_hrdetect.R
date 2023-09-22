#! /usr/bin/env Rscript

library(signature.tools.lib)
library(BSgenome.Hsapiens.UCSC.hg38)
library(jsonlite)
library(deconstructSigs)
library(dplyr)
library(StructuralVariantAnnotation)

'%ni%' <- function(x,y)!('%in%'(x,y))

call_hrdetect <- function(boots               ,
                          genomeVersion       ,
                          sample_name         ,
                          SVrefSigs           ,
                          SNVrefSigs          ,
                          snv_vcf_location    ,
                          indel_vcf_location  ,
                          SV_vcf_location     ,
                          LOH_seg_file        
){
  print('pre-processing data')
  
  # import signatures
  SV_sigs  <- read.table(SVrefSigs, sep = "\t", header = TRUE)
  SNV_sigs  <- read.table(SNVrefSigs, sep = "\t", header = TRUE)
  
  # pre-process data
  ## TODO: try using SNV vcf to estimate LOH (using PLINK or something)
  seg.data      <- read.table(LOH_seg_file, sep="\t", header=TRUE)
  
  ## TODO: read in ONE VCF with BOTH SNV + In/Del, then split
  indels_class  <- vcfToIndelsClassification(indel_vcf_location, sample_name, genome.v = genomeVersion)

  snv_df <- try(read.table(snv_vcf_location,sep = "\t", header = FALSE))
  names(snv_df)[c(1,2,4,5)] <- c("Chromosome","Start_Position","Reference_Allele","Allele")
  snv_df$Tumor_Sample_Barcode <- sample_name
  
  SV_catalogue <- SV_vcf_cataloger(SV_vcf_location, sample_name)
  
  cat('starting bootstrapping')
  
  hrdetect_boots <- c("del.mh.prop"  =numeric(),"SNV3"  =numeric(),"SV3"  =numeric(),"SV5"  =numeric(),"hrd"  =numeric(),"SNV8"  =numeric(),"intercept"  =numeric(),
                      "del.mh.prop.w"=numeric(),"SNV3.w"=numeric(),"SV3.w"=numeric(),"SV5.w"=numeric(),"hrd.w"=numeric(),"SNV8.w"=numeric(),"Probability"=numeric())
  
  for(boot in c(1:boots)){
    if(boot %% 10 == 0){ cat(boot)}else{ cat('.')  }
    
    ## Summarize data
    LOH_ls    <- summarize_LOH(seg.data)
    indel_ls  <- summarize_indels( indels_class )
    SV_ls     <- summarize_SVs(SV_catalogue, SV_sigs, sample_name)
    SNV_ls    <- summarize_SNVs_dcSigs(snv_df, SNV_sigs, sample_name)
    
    ## Perform test
    input_matrix <- matrix(NA, nrow = 1, ncol = 6,
                            dimnames = list(
                             sample_name,
                             c("del.mh.prop", "SNV3", "SV3", "SV5", "hrd", "SNV8")
                            )
                           )
    
    input_matrix[sample_name,"del.mh.prop"] <- indel_ls$sim_proportions["del.mh.prop"]
    input_matrix[sample_name,"SNV3"] <- SNV_ls$SBS3
    input_matrix[sample_name,"SNV8"] <- SNV_ls$SBS8
    input_matrix[sample_name,"SV3"]  <- SV_ls$SV_sigtools_exposures$RefSigR3
    input_matrix[sample_name,"SV5"]  <- SV_ls$SV_sigtools_exposures$RefSigR5
    input_matrix[sample_name,"hrd"]  <- unlist(LOH_ls[1])
    
    suppressMessages(
      HRDetect_res <- HRDetect_pipeline(data_matrix = input_matrix, bootstrapHRDetectScores = FALSE)
    )

    boot_results <- c(HRDetect_res$data_matrix, HRDetect_res$hrdetect_output)
    hrdetect_boots <- rbind.data.frame(hrdetect_boots,boot_results )
    names(hrdetect_boots) <- c(colnames(HRDetect_res$data_matrix), paste0(colnames(HRDetect_res$hrdetect_output),".w"))
    
  }   
  cat('done bootstrapping')
  
  quantiles <- lapply(hrdetect_boots, function (x) quantile(x, probs = c(5, 50, 95)/100))
  
  quantiles <- c( "sample_name"=sample_name, quantiles  )
  quantiles.json <- jsonlite::toJSON(quantiles,pretty=TRUE,auto_unbox=TRUE)
  write(quantiles.json, file = paste0(sample_name,".signatures.json"))
  
  SBS.signatures <- c("sample_name"=sample_name, SNV_ls)
  SV.signatures <- c("sample_name"=sample_name, SV_ls$SV_sigtools_exposures)
  
  SBS.signatures.JSON <- jsonlite::toJSON(SBS.signatures,pretty=TRUE,auto_unbox=TRUE)
  SV.signatures.JSON <- jsonlite::toJSON(SV.signatures,pretty=TRUE,auto_unbox=TRUE)
  
  write(SBS.signatures.JSON, file = paste0(sample_name,".exposures.SBS.json"))
  write(SV.signatures.JSON, file = paste0(sample_name,".exposures.SV.json"))
  
  snv_catalogue <- mut.to.sigs.input(mut.ref=snv_df,
                                  sample.id="Tumor_Sample_Barcode",
                                  chr="Chromosome",
                                  pos="Start_Position",
                                  ref="Reference_Allele",
                                  alt="Allele",
                                  bsg=BSgenome.Hsapiens.UCSC.hg38)
 
  SBS.catalogue.JSON <- jsonlite::toJSON(snv_catalogue,pretty=TRUE,auto_unbox=TRUE)
  SV.catalog.JSON <- jsonlite::toJSON(SV_ls$SV_sigtools_catalog,pretty=TRUE,auto_unbox=TRUE)
  ID.catalog.JSON <- jsonlite::toJSON(indels_class$count_proportion,pretty=TRUE,auto_unbox=TRUE)
  
  write(SV.catalog.JSON, file = paste0(sample_name,".catalog.SV.json"))
  write(ID.catalog.JSON, file = paste0(sample_name,".catalog.ID.json"))
  write(SBS.catalogue.JSON, file = paste0(sample_name,".catalog.SBS.json"))
  
  cat('done writing files')
  
}

reformat_toJSON <- function(inCol){
  catalog <-   as.data.frame(t(inCol[,1])) 
  names(catalog) <- rownames(inCol) 
  return(catalog)
}

setColNames <- function (object = nm, nm) {
  
  colnames(object) <- nm
  object
  
}

sigTools_formatter <- function(input,sampleName){
  
  cat_list <- list()
  names(input)[1] <- "catalogue"
  colnames(input$catalogue) <- sampleName
  cat_list[[1]] <- input$catalogue
  catalogues <- do.call(cbind,cat_list)
  return(catalogues)
  
}

summarize_indels <- function(indels_class){
  
  #sigtools indel classification
  
  indel_info <- indels_class$count_proportion[c("all.indels","ins","del.mh","del.rep","del.none","del.mh.prop","del.rep.prop","del.none.prop")]
  
  
  sim_proportions <- table(sample(1:3 , indel_info$all.indels, replace=TRUE, prob=indel_info[c(6:8)])) / indel_info$all.indels
  names(sim_proportions) <-  c("del.mh.prop","del.rep.prop","del.none.prop")
  
  
  #make indel list
  indel_ls <- list(unlist(indel_info[1]), indel_info, sim_proportions)
  names(indel_ls) <- c("indelCount","indel_sigtools_catalog", "sim_proportions")
  

  return(indel_ls)
}  

summarize_LOH <- function(seg.data, segs_to_sample=40){
  # humans have 40 chromosome arms, so default segs_to_sample is 40
  library(dplyr)
  
  seg.data$length <- seg.data$end - seg.data$start
  sum_of_segment_lengths <- sum(seg.data$length)
  
  LOH.data <- seg.data[seg.data$minorAlleleCopyNumber < 0.5 & seg.data$majorAlleleCopyNumber >= 0.5,]
  sum_of_LOH_lengths <- sum(LOH.data$length)
  
  LOH_probabilities <- c(sum_of_LOH_lengths/sum_of_segment_lengths, 1-sum_of_LOH_lengths/sum_of_segment_lengths)

  LOH_ls <- table(sample(1:2 , segs_to_sample, replace=TRUE, prob=LOH_probabilities))[1] 
  
  
  names(LOH_ls) <- c("LOHcount")
  
  return(LOH_ls)
  
}

reformat_signatures <- function(SNV_sigs){
  rownames(SNV_sigs) <- SNV_sigs[,1]
  SNV_sigs <- SNV_sigs[,-1]
  SNV_sigs_t <- as.data.frame(t(SNV_sigs))
  return(SNV_sigs_t)
}

summarize_SNVs_dcSigs <- function(snv_df, SNV_sigs, sample_name ){
  
  n_snv <- nrow(snv_df)
  
  snv_df <- dplyr::sample_n(snv_df, round(n_snv*0.8), replace = F)
  
  SNV_sigs_reformatted <- reformat_signatures(SNV_sigs)
  # read input data
  sigs_input <- mut.to.sigs.input(mut.ref=snv_df,
                                  sample.id="Tumor_Sample_Barcode",
                                  chr="Chromosome",
                                  pos="Start_Position",
                                  ref="Reference_Allele",
                                  alt="Allele",
                                  bsg=BSgenome.Hsapiens.UCSC.hg38)
  
  # calculate a sample
  sample_sigs <- whichSignatures(tumor.ref=sigs_input,
                                 signatures.ref=SNV_sigs_reformatted, 
                                 sample.id=sample_name,
                                 contexts.needed=TRUE,
                                 tri.counts.method='exome')
  
  
  # get signature weights
  weights <- sample_sigs$weights
  df_nums <- weights * n_snv
  
  return(df_nums)
  
}

summarize_SNVs_sigTools <- function(snv_catalogue, SNV_sigs, sample_name, giniThresholdScaling=2, threshold_percent=1){
  # Deprecated in .wdl, uses signature.tools.lib version of signatures rather than deconstructSig

  col_names <- c("SNVCount","classic_sigs","SNV_catalog")
  
  snv_catalogue_reformat <- sigTools_formatter(input=snv_catalogue, sampleName=sample_name)
  
  subs_res <- Fit(catalogues = snv_catalogue_reformat,
                           signatures = SNV_sigs,
                           useBootstrap = TRUE, 
                           nboot = 200,
                          exposureFilterType = "giniScaledThreshold",
                          giniThresholdScaling = giniThresholdScaling, 
                          threshold_percent = threshold_percent
                  )
  
  #reformat for JSON
  classic_fit <- as.data.frame(t(subs_res$exposures[1,]))
  
  #make list
  SNV_ls <- list(sum(snv_catalogue$catalogue),classic_fit,snv_catalogue_reformat)
  names(SNV_ls) <- col_names
  
  return(SNV_ls)
  
} 



summarize_SVs <- function(SV_catalogue, SV_sigs, sampleName , giniThresholdScaling=2, threshold_percent=1){
    

  SV_catalogue_reformat <-  sigTools_formatter(SV_catalogue, sampleName = sample_name)
  
  #fit SV signature
  SV_fit_sigs_all <- Fit(catalogues = SV_catalogue_reformat,
                         signatures = SV_sigs,
                         useBootstrap = TRUE,
                         nboot = 200,
                         exposureFilterType = "giniScaledThreshold",
                         giniThresholdScaling = giniThresholdScaling, 
                         threshold_percent = threshold_percent
                        )
  
  #extract signature exposures
  SV_exposure <- as.data.frame(t(SV_fit_sigs_all$exposures[1,]))
  
  #make SV list
  SV_ls <- list(SV_catalogue$rearr_catalogue,SV_exposure)
  
  names(SV_ls) <- c("SV_sigtools_catalog","SV_sigtools_exposures")
    
  return(SV_ls)
  
}

simpleEventType <- function(gr) {
  #https://github.com/PapenfussLab/gridss/blob/master/example/simple-event-annotation.R
  pgr = partner(gr)
  
  gr$simple_svtype <-
    ifelse(seqnames(gr) != seqnames(pgr), "translocation", # inter-chromosomosal
         ifelse(strand(gr) == strand(pgr), "inversion",
                ifelse(gr$insLen >= abs(gr$svLen) * 0.7, "INS",
                       ifelse(xor(start(gr) < start(pgr), strand(gr) == "-"), "deletion",
                              "tandem-duplication"))))
  return(gr)
}

SV_vcf_cataloger <- function(SV_vcf_location, sample_name, genome="hg38"){
  
  vcf <- VariantAnnotation::readVcf(SV_vcf_location, genome)

  gr <- StructuralVariantAnnotation::breakpointRanges(vcf, nominalPosition=T, inferMissingBreakends=TRUE)
  
  gr <- simpleEventType(gr)
  
  simplebed <- data.frame(
    chrom1 = seqnames(gr),
    start1 = start(gr),
    end1 = end(gr),
    chrom2 = seqnames(partner(gr)),
    start2 = start(partner(gr)),
    end2 = end(partner(gr)),
    sample = sample_name,
    svclass = gr$simple_svtype,
    score = gr$FILTER,
    strand = "."
  )
  
  simplebed <- simplebed %>% filter(svclass != "translocation")
  # Just the lower of the two breakends, so we don't output everything twice
  simplebed <- simplebed[order(simplebed$chrom1, simplebed$start1, simplebed$chrom2, simplebed$start2),]
  simplebed <- simplebed[!duplicated(simplebed),]

  SV_catalogue <- bedpeToRearrCatalogue(simplebed)
  return(SV_catalogue)
} 

