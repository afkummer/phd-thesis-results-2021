#!/usr/bin/env Rscript

#
# This script expects to have importData.R sourc'd!
#

# Compute the means.
means <- finals %>%
   group_by(instance) %>%
   summarize(
      count = n(),
      cost.min = min(cost),
      cost.max = max(cost),
      cost.mean = mean(cost),
      cost.sd = sd(cost),

      best.sol.dist = first(dist[cost <= min(cost)]),
      best.sol.tard = first(tard[cost <= min(cost)]),
      best.sol.tmax = first(tmax[cost <= min(cost)]),
      
      dist.mean = mean(dist),
      tard.mean = mean(tard),
      tmax.mean = mean(tmax),

      time.mean = mean(time),
      time.sd = sd(time),

      gens.mean = mean(generation),
      gens.sd = sd(generation),
      
      li.gen.mean = mean(last.improvement.gen),
      li.time.mean = mean(last.improvement.time)
   )

means <- with.instance.metadata(means) 
means <- means %>% arrange(nodes, instance.id)
write.csv(means, "means.csv", row.names=F)
