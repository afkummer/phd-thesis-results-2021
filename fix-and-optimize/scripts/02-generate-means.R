#!/usr/bin/env Rscript

require(dplyr)
require(data.table)

generate_means <- function(data) {
   data_mean <- data %>%
      # Adds a column with the value from the initial solution.
      # These initial solutions are produced by a deterministic algorithm.
      group_by(instance) %>%
      mutate(obj.initial = first(obj[iter == 0])) %>%
      ungroup() %>%
      # Filter the data to consider only the results of 
      # the last iteration of each run.
      group_by(instance, seed) %>%
      dplyr::filter(iter == max(iter)) %>%
      ungroup() %>%
      # Then compute some metrics regarding all the runs with distinct seeds.
      group_by(instance) %>%
      summarize(
         subset = first(subset),
         iid = first(iid),
         iter.mean = mean(iter),
         iter.sd = sd(iter),
         iter.max = max(iter),
         iter.min = min(iter),
         time.mean = mean(time),
         time.sd = sd(time),
         memusage.mean = mean(memusage),
         memusage.sd = sd(memusage),
         cost.initial = first(obj.initial),
         cost.mean = mean(obj),
         cost.sd = sd(obj),
         cost.min = min(obj),
         cost.max = max(obj),
         dist.mean = mean(dist),
         dist.sd = sd(dist),
         tard.mean = mean(tard),
         tard.sd = sd(tard),
         tmax.mean = mean(tmax),
         tmax.sd = sd(tmax)
      ) %>%
      ungroup() %>%
      arrange(subset, iid)
   return(data_mean)
}

# Checks for command line arguments.
args <- commandArgs(trailingOnly = T)

if (length(args) != 2) {
   cat("Usage: ./02-generate-means.R <input CSV> <output CSV>\n")
   q(status = 1)
}

in_csv <- args[1]
out_csv <- args[2]

cat("-----------------------------\n")
cat("--- Summarizer of results ---\n")
cat("-----------------------------\n")

cat("Importing data from", in_csv, "\b...\n")
all <- fread(in_csv)

cat("Calculating averge results per instance file...\n")
data <- generate_means(all)

cat("Writing data to", out_csv, "\b...\n")
fwrite(data, out_csv)

cat("Done!\n")
