#!/usr/bin/env Rscript

require(dplyr)
require(data.table)

generate_means <- function(data) {
   data_mean <- data %>%

      group_by(instance, seed) %>%
      # Compute the number of reset, IPR, and elite exchange of each run.
      mutate(
         reset.count = sum(op.rst),
         ipr.count = sum(op.pr),
         xelite.count = sum(op.xe),
      ) %>%
      
      # Then filter the data to consider only the results of 
      # the last generation the algorithm evolved.
      group_by(instance, seed) %>%
      dplyr::filter(generation == max(generation)) %>%
      ungroup() %>%
      
      # Then compute some metrics regarding all the runs with distinct seeds.
      group_by(instance) %>%
      summarize(
         subset = first(subset),
         iid = first(iid),

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
         tmax.sd = sd(tmax),

         reset.mean = mean(reset.count),
         reset.sd = sd(reset.count),

         ipr.mean = mean(ipr.count),
         ipr.sd = sd(ipr.count),

         xelite.mean = mean(xelite.count),
         xelite.sd = sd(xelite.count)
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
