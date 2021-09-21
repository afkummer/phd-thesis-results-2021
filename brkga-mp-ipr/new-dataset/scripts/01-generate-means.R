#!/usr/bin/env Rscript

require(dplyr)
require(data.table)

fix_name <- function(s) {
   return(substr(s, 1, nchar(s)-4))
}
fix_name.Vec <- Vectorize(fix_name)

# Checks for command line arguments.
args <- commandArgs(trailingOnly = T)

if (length(args) != 2) {
   cat("Usage: ./01-generate-means.R <input CSV> <output CSV>\n")
   q(status = 1)
}

in_csv <- args[1]
out_csv <- args[2]

cat("-----------------------------\n")
cat("--- Summarizer of results ---\n")
cat("-----------------------------\n")

cat("(1/5) Importing results...\n")
all <- fread(in_csv) %>% mutate(instance = fix_name.Vec(instance))

cat("(2/5) Importing dataset characteristics...\n")
ds <- fread("../raw-csv/dataset-features.csv")

cat("(3/5) Calculating averge results per instance file...\n")
finals <- all %>%
   group_by(instance) %>%
   dplyr::filter(generation >= max(generation)) %>%
   summarize(
      generation = mean(generation),

      time.mean = mean(time),
      time.sd = sd(time),

      cost.mean = mean(cost),
      cost.sd = sd(cost),
      cost.min = min(cost),
      cost.max = max(cost),

      dist.mean = mean(dist),
      dist.sd = sd(dist),

      tard.mean = mean(tard),
      tard.sd = sd(tard),

      tmax.mean = mean(tmax),
      tmax.sd = sd(tmax)
   )

# # Remembers that dplyr only adds the suffix if the two data-frames
# # have aby columns with the same names.
cat("(4/5) Aggregating data...\n")
finals.agg <- inner_join(finals, ds, by = "instance", suffix = c(".result", ".ds")) %>%
   arrange(
      nodes,
      selection,
      -gap
   )
stopifnot(nrow(finals.agg) == nrow(finals))

cat("(5/5) Writing data to", out_csv, "\b...\n")
fwrite(finals.agg, out_csv)

cat("Done!\n")
