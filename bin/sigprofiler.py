#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Load dependencies
"""

import os
import sys
import shutil
import pandas as pd
import argparse
import logging
from SigProfilerMatrixGenerator import install as genInstall
from SigProfilerExtractor import sigpro as sig

"""
CMD line parser
"""

def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Full workflow package from SigProfiler which generates both matrices and the according Signature assignment.",
        epilog="Example: NA",
    )
    parser.add_argument(
        "--fileytpe",
        type=str,
        help="Defines the provided input filetype - GDC-MAF or a VCF-containing folder",
        default="vcf"
    )
    parser.add_argument(
        "--input",
        type=str,
        help="Path to input data folder",
        default=""
    )
    parser.add_argument(
        "--output_pattern",
        type=str,
        help="Identifier of the output files.",
        default=""
    )
    parser.add_argument(
        "--min",
        type=int,
        help="Define the minimal amount of signatures which should be assigned.",
        default=4
    )
    parser.add_argument(
        "--max",
        type=int,
        help="Define the maximal amount of signatures which should be assigned.",
        default=30
    )
    parser.add_argument(
        "--ref",
        type=str,
        help="Reference genome from which the data was derived.",
        default="GRCh38"
    )
    parser.add_argument(
        "--nmf",
        type=int,
        help="Amount of NMF replicates SigProfiler should perform before converging",
        default=100
    )
    parser.add_argument(
        "--exome",
        type=bool,
        help="Was the input data derived from Exome/Panel data or WGS data?",
        action='store_true'
    )
    parser.add_argument(
        "--threads",
        type=int,
        help="Amount of threads which should be assigned to SigProfiler",
        default=8
    )
    return parser.parse_args(argv)

############################################################################################################

######################################################### Define analysis functions - MAF case

### Function to check if the minimal amount of columns are present in the input MAF to be converted to Sigprofiler format
def maf_formattest(maf_totest):
    gdc_format_header = ["Hugo_Symbol", "Chromosome", "Start_position", "End_position", "Strand", "Variant_Classification", "Variant_Type", "Reference_Allele", "Tumor_Seq_Allele1", "Tumor_Seq_Allele2", "dbSNP_RS",
                        "dbSNP_Val_Status", "Project_Code", "Donor_ID"] ### minimal required columns
    checkval = []
    for column in gdc_format_header:
        if column in maf_totest.columns:
            checkval.append(True)
        else:
            checkval.append(False)
    format_test = all(checkval)
    return format_test

### Function to convert MAF input format to SigProfiler input MAF convention, hard-coded
def mafconverter(maf_toconvert, ref_version):
    maf_out_raw = pd.DataFrame(columns=["Hugo", "Entrez", "Center", "Genome", "Chrom", "Start", "End", "Strand", "Classification", "Type", "Ref", "Alt1", "Alt2", "dbSNP", "SNP_Val_status", "Tumor_sample"])
    maf_out_raw["Hugo"] = maf_toconvert["Hugo_Symbol"]
    maf_out_raw["Entrez"] = "."
    maf_out_raw["Center"] = "ICGC"
    maf_out_raw["Genome"] = ref_version
    maf_out_raw["Chrom"] = maf_toconvert["Chromosome"]
    maf_out_raw["Start"] = maf_toconvert["Start_position"]
    maf_out_raw["End"] = maf_toconvert["End_position"]
    maf_out_raw["Strand"] = maf_toconvert["Strand"]
    maf_out_raw["Classification"] = maf_toconvert["Variant_Classification"]
    maf_out_raw["Type"] = maf_toconvert["Variant_Type"]
    maf_out_raw["Ref"] = maf_toconvert["Reference_Allele"]
    maf_out_raw["Alt1"] = maf_toconvert["Tumor_Seq_Allele1"]
    maf_out_raw["Alt2"] = maf_toconvert["Tumor_Seq_Allele2"]
    maf_out_raw["dbSNP"] = maf_toconvert["dbSNP_RS"]
    maf_out_raw["SNP_Val_status"] = maf_toconvert["dbSNP_Val_Status"]
    maf_out_raw["Tumor_sample"] = maf_toconvert[['Project_Code', 'Donor_ID']].apply(lambda x: '_'.join(x), axis=1)
    return maf_out_raw

###
def maf_input_routine(in_maf, ref_version):
        maf_raw = pd.read_table(in_maf) ### expects MAF format following GDC protected data structure
        format_conform = maf_formattest(maf_raw)
        if format_conform == True:
            converted_maf = mafconverter(maf_raw, ref_version)
            return converted_maf
        else:
            logger.error(f"The provided MAF file {maf_raw} does not follow GDC format requirements. Please recheck your input MAF.")
            raise ValueError(f"The provided MAF file {maf_raw} does not follow GDC format requirements. Please recheck your input MAF.")

logger = logging.getLogger()

############################################################################################################
'''
Define the signature assignment routine
'''

def sigpro_func(filetype, output_pattern, ref, min, max, nmf, threads, exome):
    sig.sigProfilerExtractor(filetype, output_pattern, "./matgen", reference_genome=ref, minimum_signatures=min, maximum_signatures=max, nmf_replicates=nmf, cpu=threads, exome=exome)

############################################################################################################

def main(argv=None):
    args = parse_args(argv)
    logging.basicConfig(filename='sigprofiler.log', filemode='w', level=args.l, format="%(asctime)s : [%(levelname)s] %(message)s")
    if args.filetype in ["maf", "MAF"]:
        if os.path.isfile(args.input):
            maf_for_analysis = maf_input_routine(args.input, args.ref)
            os.mkdir('matgen')
            maf_for_analysis.to_csv('./matgen/' + args.output_pattern + '.maf', index = False, sep="\t")
            '''Install reference genome'''
            genInstall.install(args.ref, bash=True)
            '''Run the Matrix Generator Module to generate matrices for SBS96 from input data'''
            sigpro_func(args.filetype, args.output_pattern, args.ref, args.min, args.max, args.nmf, args.threads, args.exome)
        else:
            logger.error(f"The given input MAF file {args.input} was not found!")
            raise ValueError(f"The given input MAF file {args.input} was not found!")
    elif args.filetype in ["vcf", "VCF"]:
        if os.path.isdir(args.input):
            os.mkdir('matgen')
            for file in glob.glob(args.input + '/*.vcf'):
                shutil.copy(file, './matgen')
            '''Install reference genome'''
            genInstall.install(args.ref, bash=True)
            '''Run the Matrix Generator Module to generate matrices for SBS96 from input data'''
            sigpro_func(args.filetype, args.output_pattern, args.ref, args.min, args.max, args.nmf, args.threads, args.exome)
        else:
            logger.error(f"The given temporary folder {args.input} was not found!")
            raise ValueError(f"The given temporary folder {args.input} was not found!")
    else:
        logger.error(f"The provided information for the input file type is wrong. Please define either 'vcf' or 'maf'!")
        raise ValueError(f"The provided information for the input file type is wrong. Please define either 'vcf' or 'maf'!")

if __name__ == '__main__':
    sys.exit(main())
