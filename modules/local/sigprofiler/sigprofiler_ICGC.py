#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May  3 16:45:09 2023

@author: oem
"""


"""
Load dependencies
"""

import os
#import shutil
import argparse
from SigProfilerExtractor import sigpro as sig

"""
CMD line parser
"""

parser = argparse.ArgumentParser(prog='SigProfiler.py', description='Full workflow package from SigProfiler which generates both matrices and the according Signature assignment')
parser.add_argument('i', metavar='-i', type=str, help='Define input data file path (will be copied by SigProfilerMatrixGenerator)')
parser.add_argument('o', metavar='-o', type=str, help='Identifier of the output files.')
parser.add_argument('min', metavar='-min', type=int, help='Define the minimal amount of signatures which should be assigned.')
parser.add_argument('max', metavar='-max', type=int, help='Define the maximal amount of signatures which should be assigned.')
parser.add_argument('nmf', metavar='-nmf', type=int, help='Define the number of NMF replicates for signature assignment.')
parser.add_argument('cpus', metavar='-cpus', type=int, help="Amount of CPUs to use.")

args = parser.parse_args()


'''
Generate output folder separate from the matrixgenerator folder
'''

if os.path.exists('./sigpro_tmp/') == False:
    os.mkdir('sigpro_tmp')
else:
    print('Output folder already exists... continue...')

os.system('cp ' + args.i + '*  ./sigpro_tmp')


'''
Run the signature assignment procedure
'''

def sigpro_func():
    sig.sigProfilerExtractor("vcf", args.o, "./sigpro_tmp", reference_genome="GRCh38", minimum_signatures=args.min, maximum_signatures=args.max, nmf_replicates=args.nmf, cpu=args.cpus, exome=False)

if __name__ == '__main__':
    sigpro_func()


#sigout = sig.sigProfilerExtractor("vcf", args.o, "./sigpro_tmp", reference_genome="GRCh38", minimum_signatures=args.min, maximum_signatures=args.max, nmf_replicates=args.nmf, cpu=args.cpus, exome=False)

'''
To-Do: Export all results from SigProfiler into an accessible output folder
'''

