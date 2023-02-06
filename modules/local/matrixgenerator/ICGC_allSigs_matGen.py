#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  6 16:38:28 2023

@author: Lancelot Seillier
"""

'''
Load dependencies
'''
import os
import shutil
import argparse
from SigProfilerMatrixGenerator.scripts import SigProfilerMatrixGeneratorFunc as matGen

'''CMD line parser'''

parser = argparse.ArgumentParser(prog='MatGenerator.py', description='Generate trinucleotide matrix using SigProfilerMatrixGenerator.')
parser.add_argument('i', metavar='--input_path', type=str, help='Define input data file path (will be copied by SigProfilerMatrixGenerator)')
parser.add_argument('o', metavar='--output_file', type=str, help='Identifier of the output files.')

args = parser.parse_args()

'''
Generate output folder
'''
if os.path.exists('./matgen_tmp/') == False:
    os.mkdir('matgen_tmp')
else:
    print('Output folder already exists... continue...')

os.system('cp ' + args.i + '*  ./matgen_tmp')

'''
Run the Matrix Generator Module to generate matrices for SBS96, DBS78 and ID83 
'''

matrices = matGen.SigProfilerMatrixGeneratorFunc(args.o, "GRCh38", "./matgen_tmp", exome=False, bed_file=None, chrom_based=False, plot=False, tsb_stat=False, seqInfo=False)
    
'''Move output files and rename if required.'''

shutil.move('./matgen_tmp/output/SBS/' + args.o + '.SBS96.all', './Trinucleotide_matrix_' + args.o + '_SBS96.txt')
shutil.move('./matgen_tmp/output/DBS/' + args.o + '.DBS78.all', './Trinucleotide_matrix_' + args.o + '_DBS78.txt')
shutil.move('./matgen_tmp/output/ID/' + args.o + '.ID83.all', './Trinucleotide_matrix_' + args.o + '_ID83.txt')