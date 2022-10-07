#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 22 10:51:36 2022

@author: Lancelot Seillier
"""

'''Import dependecies/packages'''

import pandas as pd
import os
import shutil
import argparse
import SigProfilerMatrixGenerator as refCheck
from SigProfilerMatrixGenerator.scripts import SigProfilerMatrixGeneratorFunc as matGen
from SigProfilerMatrixGenerator import install as genInstall

'''CMD line parser'''

parser = argparse.ArgumentParser(prog='MatGenerator.py', description='Generate trinucleotide matrix using SigProfilerMatrixGenerator.')
parser.add_argument('i', metavar='--input_path', type=str, help='Define input data file path (will be copied by SigProfilerMatrixGenerator)')
parser.add_argument('o', metavar='--output_file', type=str, help='Define the name of the output MAF file.')
parser.add_argument('ref', metavar='--reference_genome', type=str, help='Genome reference on which trinucleotide context should be interpolated (opt: GRCh37/38)')

args = parser.parse_args()


'''Read input data and generate df for data conversion.'''

maf_raw = pd.read_table(args.i)
maf_out_raw = pd.DataFrame(columns=["Hugo", "Entrez", "Center", "Genome", "Chrom", "Start", "End", "Strand", "Classification", "Type", "Ref", "Alt1", "Alt2", "dbSNP", "SNP_Val_status", "Tumor_sample"])

'''Assign values to the converted MAF format '''

maf_out_raw["Hugo"] = maf_raw["Hugo_Symbol"]
maf_out_raw["Entrez"] = "."
maf_out_raw["Center"] = "ICGC_consensus"
maf_out_raw["Genome"] = "GRCh37"
maf_out_raw["Chrom"] = maf_raw["Chromosome"]
maf_out_raw["Start"] = maf_raw["Start_position"]
maf_out_raw["End"] = maf_raw["End_position"]
maf_out_raw["Strand"] = maf_raw["Strand"]
maf_out_raw["Classification"] = maf_raw["Variant_Classification"]
maf_out_raw["Type"] = maf_raw["Variant_Type"]
maf_out_raw["Ref"] = maf_raw["Reference_Allele"]
maf_out_raw["Alt1"] = maf_raw["Tumor_Seq_Allele1"]
maf_out_raw["Alt2"] = maf_raw["Tumor_Seq_Allele2"]
maf_out_raw["dbSNP"] = maf_raw["dbSNP_RS"]
maf_out_raw["SNP_Val_status"] = maf_raw["dbSNP_Val_Status"]
maf_out_raw["Tumor_sample"] = maf_raw[['Project_Code', 'Donor_ID']].apply(lambda x: '_'.join(x), axis=1)

'''Print new MAF format to the folder under investigation '''

if os.path.exists('./maf/') == False:
    os.mkdir('maf')
else:
    print('Output folder already exists... continue...')
    
maf_out_raw.to_csv('./maf/' + args.o + '.maf', index = False, sep="\t")

'''Generate the trinucleotide matrix using SigProfilerMatrixGenrator'''

'''INSTALL REFERENCE GENOME - HAS TO BE PERFORMED ONLY ONCE FOR EACH RESPECTIVE GENOME REFERENCE '''

if os.path.exists(os.path.join(refCheck.__path__[0], 'references/chromosomes/tsb/', args.ref)) == True:
    print('Reference genome already installed, procede with matrix generation...')
else:
    genInstall.install(args.ref, rsync=False)

matrices = matGen.SigProfilerMatrixGeneratorFunc(args.o, args.ref, './maf', exome=False, bed_file=None, chrom_based=False, plot=False, tsb_stat=False, seqInfo=False)

'''Move output and rename if required.'''

shutil.move('./maf/output/SBS/' + args.o + '.SBS96.all', './Trinucleotide_matrix_' + args.o + '.txt')

print('Task completed!')
