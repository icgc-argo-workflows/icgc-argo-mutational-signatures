#! /usr/bin/env Rscript

#basedir <- paste(Sys.getenv(c("HRDETECT_ROOT")), sep='/')
#source(paste0(basedir, "/call_hrdetect.R"))
source("/.mounts/labs/CGI/scratch/fbeaudry/wdl/sigtools_workflow/call_hrdetect.R")

library(optparse)

option_list = list(
  make_option(c("-s", "--sampleName"), type="character", default=NULL, help="sample name", metavar="character"),
  make_option(c("-r", "--SVrefSigs"), type="character", default=NULL, help="structural variant reference signatures", metavar="character"),
  make_option(c("-R", "--SNVrefSigs"), type="character", default=NULL, help="single nucleotide polymorphism reference signatures", metavar="character"),
  make_option(c("-S", "--snvFile"), type="character", default=NULL, help="SNV vcf file", metavar="character"),
  make_option(c("-I", "--indelFile"), type="character", default=NULL, help="indel vcf file", metavar="character"),
  make_option(c("-V", "--SVFile"), type="character", default=NULL, help="Structural variant file", metavar="character"),
  make_option(c("-L", "--LOHFile"), type="character", default=NULL, help="LOH file", metavar="character"),
  make_option(c("-b", "--bootstraps"), type="numeric", default=2500, help="number of bootstraps for signature detection", metavar="numeric"),
  make_option(c("-g", "--genomeVersion"), type="character", default="hg38", help="genome version", metavar="character"),
  make_option(c("-i", "--indelCutoff"), type="numeric", default=10, help="minimum number of indels for analysis", metavar="numeric"),
  make_option(c("-c", "--snvCutoff"), type="numeric", default=10, help="minimum number of snvs for analysis", metavar="numeric")
)

opt_parser <- OptionParser(option_list=option_list, add_help_option=FALSE)
opt <- parse_args(opt_parser)

boots               <-  opt$bootstraps
genomeVersion       <-  opt$genomeVersion
indelCutoff         <-  opt$indelCutoff
snvCutoff           <-  opt$snvCutoff
sample_name         <-  opt$sampleName
SVrefSigs           <-  opt$SVrefSigs
SNVrefSigs         <-  opt$SNVrefSigs
snv_vcf_location    <-  opt$snvFile
indel_vcf_location  <-  opt$indelFile
SV_vcf_location     <-  opt$SVFile
LOH_seg_file        <-  opt$LOHFile

SV_vcf <- try(read.table(SV_vcf_location,sep = "\t", header = TRUE))
indel_vcf <- try(read.table(indel_vcf_location,sep = "\t", header = TRUE))
snv_vcf <- try(read.table(snv_vcf_location,sep = "\t", header = TRUE))

if("try-error" %in% class(snv_vcf) | "try-error" %in% class(indel_vcf) | "try-error" %in% class(SV_vcf)) {
  
  print("some data missing, no HRD call!")
  
} else if( nrow(snv_vcf) < snvCutoff | nrow(indel_vcf) < indelCutoff ){
  
  print("some calls too few, no HRD call!")
  
} else {
    
  call_hrdetect(boots               ,
                genomeVersion       ,
                sample_name         ,
                SVrefSigs           ,
                SNVrefSigs          ,
                snv_vcf_location    ,
                indel_vcf_location  ,
                SV_vcf_location     ,
                LOH_seg_file        
  )
  
}
