#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''
Load dependencies
'''

import os
import sys
import shutil
import argparse
import logging
import glob
import pandas as pd
from SigProfilerMatrixGenerator import install as genInstall
from SigProfilerMatrixGenerator.scripts import SigProfilerMatrixGeneratorFunc as matGen

'''CMD line parser'''

def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Copy and convert VCF input files into the SBS96 matrix for BRCAness derivation.",
        epilog="Example: NA",
    )
    parser.add_argument(
        "--filetype",
        type=str,
        help="Defines the provided input filetype - GDC-MAF or a VCF-containing folder",
        default="vcf"
    )
    parser.add_argument(
        "--input",
        type=str,
        help="Still not sure what this is.:D",
        default="tmpDir"
    )
    parser.add_argument(
        "--output_pattern",
        type=str,
        help="Output file naming pattern",
        default="matgen_out"
    )
    parser.add_argument(
        "--ref",
        type=str,
        help="Reference genome from which the data was derived.",
        default="GRCh38"
    )
    parser.add_argument(
        "--exome",
        type=bool,
        help="Was the input data derived from Exome/Panel data or WGS data?",
        default=False
    )
    parser.add_argument(
        "--l",
        help="The desired log level (default INFO).",
        choices=("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"),
        default="INFO",
    )
    return parser.parse_args(argv)

logger = logging.getLogger()

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

######################################################### MAIN SCRIPT

def main(argv=None):
    args = parse_args(argv)
    logging.basicConfig(filename='matrixgenerator.log', filemode='w', level=args.l, format="%(asctime)s : [%(levelname)s] %(message)s")
    if args.filetype in ["maf", "MAF"]:
        if os.path.isfile(args.input):
            maf_for_analysis = maf_input_routine(args.input, args.ref)
            os.mkdir('matgen')
            maf_for_analysis.to_csv('./matgen/' + args.output_pattern + '.maf', index = False, sep="\t")
            '''Install reference genome'''
            genInstall.install(args.ref, bash=True)
            '''Run the Matrix Generator Module to generate matrices for SBS96 from input data'''
            matrices = matGen.SigProfilerMatrixGeneratorFunc(args.output_pattern, args.ref, './matgen', exome=args.exome, bed_file=None, chrom_based=False, plot=False, tsb_stat=False, seqInfo=False)
            '''Move output files and rename if required.'''
            for file in glob.glob("./matgen/output/SBS/*.SBS96*"):
                shutil.move(file, './Trinucleotide_matrix_' + args.output_pattern + '_SBS96.txt')
            for file in glob.glob("./matgen/output/DBS/*.DBS78*"):
                shutil.move(file, './Trinucleotide_matrix_' + args.output_pattern + '_DBS78.txt')
            for file in glob.glob("./matgen/output/ID/*.ID83*"):
                shutil.move(file, './Trinucleotide_matrix_' + args.output_pattern + '_ID83.txt')
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
            matrices = matGen.SigProfilerMatrixGeneratorFunc(args.output_pattern, args.ref, './matgen', exome=args.exome, bed_file=None, chrom_based=False, plot=False, tsb_stat=False, seqInfo=False)
            '''Move output files and rename if required.'''
            for file in glob.glob("./matgen/output/SBS/*.SBS96*"):
                shutil.move(file, './Trinucleotide_matrix_' + args.output_pattern + '_SBS96.txt')
            for file in glob.glob("./matgen/output/DBS/*.DBS78*"):
                shutil.move(file, './Trinucleotide_matrix_' + args.output_pattern + '_DBS78.txt')
            for file in glob.glob("./matgen/output/ID/*.ID83*"):
                shutil.move(file, './Trinucleotide_matrix_' + args.output_pattern + '_ID83.txt')
        else:
            logger.error(f"The given temporary folder {args.input} was not found!")
            raise ValueError(f"The given temporary folder {args.input} was not found!")
    else:
        logger.error(f"The provided information for the input file type is wrong. Please define either 'vcf' or 'maf'!")
        raise ValueError(f"The provided information for the input file type is wrong. Please define either 'vcf' or 'maf'!")


if __name__ == "__main__":
    sys.exit(main())
