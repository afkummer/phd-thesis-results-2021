#!/usr/bin/env Rscript

source("00-utils.R")

# Checks the command line args.
args <- commandArgs(trailingOnly = T)

if (length(args) != 2) {
   cat("Usage: ./01-fix_names.R <input CSV> <output CSV>\n")
   q(status = 1)
}

in_csv <- args[1]
out_csv <- args[2]

cat("-------------------------\n")
cat("--- Naming translator ---\n")
cat("-------------------------\n")

cat("Importing data from", in_csv, "\b...\n")
all <- fread(in_csv)

cat("\n\nFixing instance names...\n")
all.fx <- format_mk_instance_name_df(all)

cat("\n\nWriting data to", out_csv, "\b...\n")
fwrite(all.fx, out_csv)

cat("Done!\n")
