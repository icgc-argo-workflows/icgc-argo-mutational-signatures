#!/usr/bin/env python3

import argparse
from SigProfilerAssignment import Analyzer as Analyze

parser = argparse.ArgumentParser(description='Assigns mutation counts using SigProfilerAssignment.')

parser.add_argument('input', type=str, help='input mutation counts file')

parser.add_argument('output', type=str, help='output directory')

parser.add_argument('-e', '--exome', type=bool, default = False, 
                    help='input are exome counts')

args = parser.parse_args()


## if exome
if args.exome is not None:
    exome = True

build = "GRCh38"

## V1 for SBS variants only, will adapt for DBS and ID in next version

## Fit COSMIC signatures 
Analyze.cosmic_fit(args.input,  
args.output, 
signatures=None, ## this is where we input custom signature sets 
genome_build=build,  
make_plots=True, 
exome=exome,
collapse_to_SBS96=True, 
verbose=False)

