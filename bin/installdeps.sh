#!/usr/bin/env bash

# Create conda environement
conda create --name icgcmutsig --file ./requirements.txt

# Install SigProfiler suite
pip3 install SigProfilerExtractor==1.1.21
pip3 install SigProfilerMatrixGenerator==1.2.14

# Call the reference installation module
python3 ./refinstall.py
