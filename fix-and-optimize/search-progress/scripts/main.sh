#!/bin/bash

#
# This script has the main purpose to illustrate the intended use of all the 
# scripts from this directory. If had to change something, you can either
# use this `main.sh` script to re-trigger all the analysis, or you can 
# only run the script you modified.
#

printf "(1/4) Expanding result sets...\n"
xzcat ../raw-csv/guided-only.csv.xz > ../out/guided-only.csv
xzcat ../raw-csv/random-guided.csv.xz  > ../out/random-guided.csv
xzcat ../raw-csv/random-only.csv.xz  > ../out/random-only.csv

printf "\n(2/4) Fixing instance names...\n"
Rscript ./01-fix-names.R ../out/guided-only.csv ../out/guided-only.fixed.csv
Rscript ./01-fix-names.R ../out/random-guided.csv ../out/random-guided.fixed.csv
Rscript ./01-fix-names.R ../out/random-only.csv ../out/random-only.fixed.csv

printf "\n\n(3/4) Computing mean results...\n"
Rscript ./02-generate-means.R ../out/guided-only.fixed.csv ../out/guided-only.means.csv 
Rscript ./02-generate-means.R ../out/random-guided.fixed.csv ../out/random-guided.means.csv
Rscript ./02-generate-means.R ../out/random-only.fixed.csv ../out/random-only.means.csv

printf "\n\n(4/4) Generating graphs comparing matheuristic variations...\n"
Rscript 03-search-progress-plotter.R ../out/random-guided.fixed.csv ../out/guided-only.fixed.csv ../out/random-only.fixed.csv B2 0 9999
Rscript 03-search-progress-plotter.R ../out/random-guided.fixed.csv ../out/guided-only.fixed.csv ../out/random-only.fixed.csv B6 0 9999
Rscript 03-search-progress-plotter.R ../out/random-guided.fixed.csv ../out/guided-only.fixed.csv ../out/random-only.fixed.csv C4 0 9999
Rscript 03-search-progress-plotter.R ../out/random-guided.fixed.csv ../out/guided-only.fixed.csv ../out/random-only.fixed.csv C6 0 9999
Rscript 03-search-progress-plotter.R ../out/random-guided.fixed.csv ../out/guided-only.fixed.csv ../out/random-only.fixed.csv D9 0 9999
Rscript 03-search-progress-plotter.R ../out/random-guided.fixed.csv ../out/guided-only.fixed.csv ../out/random-only.fixed.csv D10 0 9999
Rscript 03-search-progress-plotter.R ../out/random-guided.fixed.csv ../out/guided-only.fixed.csv ../out/random-only.fixed.csv E1 0 9999
Rscript 03-search-progress-plotter.R ../out/random-guided.fixed.csv ../out/guided-only.fixed.csv ../out/random-only.fixed.csv E7 0 9999

printf "\n\nOutput data stored in $(realpath ../out)\n\n"
