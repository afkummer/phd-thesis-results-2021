#!/usr/bin/env Rscript

if (!exists("all.fx")) {
   cat("This script need the all.fx dataset to run.")
} else {

   finals <- all.fx %>%

      # Adds a column with the value from the initial solution.
      # These initial solutions are produced by a deterministic algorithm.
      group_by(instance) %>%
      mutate(obj.initial = first(obj[iter == 0])) %>%
      ungroup() %>%

      # Filter the data to consider only the final results of each run.
      group_by(instance, seed) %>%
      dplyr::filter(iter == max(iter)) %>%
      ungroup() %>%

      # Then compute some metrics regarding all the runs with distinct seeds.
      group_by(instance) %>%

      summarize(
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
      )

   fwrite(finals, "finals.csv")
}
