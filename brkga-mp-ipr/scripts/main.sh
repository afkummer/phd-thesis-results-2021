#!/bin/bash

#
# This script has the main purpose to illustrate the intended use of all the 
# scripts from this directory. If had to change something, you can either
# use this `main.sh` script to re-trigger all the analysis, or you can 
# only run the script you modified.
#

printf "(1/4) Expanding result sets...\n"
xzcat ../raw-csv/brkga-mp-ipr.csv.xz > ../out/brkga-mp-ipr.csv

printf "\n(2/4) Fixing instance names...\n"
Rscript ./01-fix-names.R ../out/brkga-mp-ipr.csv ../out/brkga-mp-ipr.fixed.csv

printf "\n\n(3/4) Computing mean results...\n"
Rscript ./02-generate-means.R ../out/brkga-mp-ipr.fixed.csv ../out/brkga-mp-ipr.means.csv

printf "\n\n(4/4) Generating comparative boxplot of solution methods...\n"
Rscript ./03-method-comparator.R

printf "\n\nOutput data stored in $(realpath ../out)\n\n"
