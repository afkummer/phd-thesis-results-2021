#!/bin/bash

#
# This script has the main purpose to illustrate the intended use of all the 
# scripts from this directory. If had to change something, you can either
# use this `main.sh` script to re-trigger all the analysis, or you can 
# only run the script you modified.
#

printf "(1/3) Expanding result sets...\n"
xzcat ../raw-csv/no-ipr.csv.xz > ../out/no-ipr.csv
xzcat ../raw-csv/no-island.csv.xz > ../out/no-island.csv
xzcat ../raw-csv/only-mp.csv.xz > ../out/only-mp.csv
xzcat ../../../brkga/raw-results.csv.xz > ../out/brkga.csv

printf "\n(2/3) Fixing instance names...\n"
Rscript ./01-fix-names.R ../out/no-ipr.csv ../out/../out/no-ipr.fixed.csv
Rscript ./01-fix-names.R ../out/no-island.csv ../out/no-island.fixed.csv
Rscript ./01-fix-names.R ../out/only-mp.csv ../out/only-mp.fixed.csv
Rscript ./01-fix-names.R ../out/brkga.csv ../out/brkga.fixed.csv

printf "\n\n(3/3) Generating comparative boxplot of solution methods...\n"
Rscript ./03-variation-comparator.R

printf "\n\nOutput data stored in $(realpath ../out)\n\n"
