#!/bin/bash

#
# This script has the main purpose to illustrate the intended use of all the 
# scripts from this directory. If had to change something, you can either
# use this `main.sh` script to re-trigger all the analysis, or you can 
# only run the script you modified.
#

printf "(1/2) Expanding result sets...\n"
xzcat ../raw-csv/brkga-mp-ipr.csv.xz > ../out/brkga-mp-ipr.csv

printf "\n\n(2/2) Computing mean results...\n"
Rscript ./01-generate-means.R ../out/brkga-mp-ipr.fixed.csv ../out/brkga-mp-ipr.means.csv

printf "\n\nOutput data stored in $(realpath ../out)\n\n"
