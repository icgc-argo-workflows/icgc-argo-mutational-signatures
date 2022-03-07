#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
  Copyright (c) 2021, ICGC ARGO

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    Alvin Ng
"""

import os
import sys
import argparse
import subprocess
import pandas as pd
from sigproSS import spss

def main():
    """
    Python implementation of tool: sigpross
    Takes a counts matrix for attribution of mutations to reference COSMIC signatures 

    """

    parser = argparse.ArgumentParser(description='Tool: sigpross')
    parser.add_argument('-i', '--input-file', dest='input_file', type=str,
                        help='Input file', required=True)
    parser.add_argument('-o', '--output-dir', dest='output_dir', type=str,
                        help='Output directory', required=True)
    parser.add_argument('-t', '--data-type', dest='type', type=str,
                        help='genome or exome type', required=True)
    parser.add_argument('-r', '--reference', dest='ref', type=str,
                        help='reference genome', required =True)
    args = parser.parse_args()

    if not os.path.isfile(args.input_file):
        sys.exit('Error: specified input file %s does not exist or is not accessible!' % args.input_file)

    if not os.path.isdir(args.output_dir):
        sys.exit('Error: specified output dir %s does not exist or is not accessible!' % args.output_dir)

    ## if input is a matrix of counts, it has to be a pandas df
    data = pd.read_csv(input_file, sep ='\t')

    if data.index.name !='MutationType':
        data = data.set_index('MutationType')

    ## works with vcf as well but will take a path WIP

    if lower(type) == 'exome':
        exome = True

    ## custom sig database available as an option.`
    spss.single_sample(data, "results", ref=ref, exome=exome)


if __name__ == "__main__":
    main()
