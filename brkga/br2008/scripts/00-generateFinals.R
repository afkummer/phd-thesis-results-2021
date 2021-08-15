#!/usr/bin/env Rscript

if (!exists("all.fx")) {
   all <- fread("all.csv")
}

finals <- all %>%

   # Filter the data to consider only the final results of each run.
   group_by(instance, seed, obj.func) %>%


   # This causes 'warnings()' to show on the output due to
   # some instances to never be feasible.
   mutate(
      feasible.gen = min(generation[cost < 1e6]),
      feasible.time = min(time[cost < 1e6])
   ) %>%


   dplyr::filter(generation == max(generation)) %>%
   ungroup() %>%

   # Then compute some metrics regarding all the runs with distinct seeds.
   group_by(instance, obj.func) %>%

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

      feas.gen.mean = mean(feasible.gen),
      feas.gen.sd = sd(feasible.gen),
      feas.gen.min = min(feasible.gen),
      feas.gen.max = max(feasible.gen),

      feas.time.mean = mean(feasible.time),
      feas.time.sd = sd(feasible.time),
      feas.time.min = min(feasible.time),
      feas.time.max = max(feasible.time)
   )

fwrite(dplyr::filter(finals, obj.func == "distance"), "finals-distance.csv")
fwrite(dplyr::filter(finals, obj.func == "preferences"), "finals-preferences.csv")
