#!/usr/bin/env Rscript

if (!exists("all.fx")) {
   cat("This script need the all.fx dataset to run.")
} else {

   finals <- all.fx %>%

      # Filter the data to consider only the final results of each run.
      group_by(instance, seed) %>%
      dplyr::filter(generation == max(generation)) %>%
      ungroup() %>%

      # Then compute some metrics regarding all the runs with distinct seeds.
      group_by(instance) %>%

      summarize(
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

   fwrite(finals, "finals.csv")
}
