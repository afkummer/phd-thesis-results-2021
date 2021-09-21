#!/usr/bin/env Rscript

require(compiler)
source("00-utils.R")

invisible(enableJIT(3))

# Checks the command line args.
args <- commandArgs(trailingOnly = T)

if (length(args) != 2) {
   cat("Usage: ./01-fix-names.R <input CSV> <output CSV>\n")
   q(status = 1)
}

in_csv <- args[1]
out_csv <- args[2]

cat("-------------------------\n")
cat("--- Naming translator ---\n")
cat("-------------------------\n")

cat("(1/3) Importing data from", in_csv, "\b...\n")
all <- fread(in_csv)

cat("(2/3) Fixing instance names...\n")
all.fx <- format_mk_instance_name_df(all) %>% arrange(subset, iid, seed, generation) 

cat("(3/3) Writing data to", out_csv, "\b...\n")
fwrite(all.fx, out_csv)

cat("Done!\n")
