#!/usr/bin/env Rscript

hasReset <- function(s) {
   if (unlist(grepl('R', s)))
      return (1)
   else
      return (0)
}

hasPR <- function(s) {
   if (unlist(grepl('P', s)))
      return (1)
   else
      return (0)
}

hasExchange <- function(s) {
   if (unlist(grepl('X', s)))
      return (1)
   else
      return (0)
}

if (!exists("all.fx")) {
   all.fx <- fread("all.fx.csv")
}

all.fx <- all.fx %>%

   # Expand results with R P X operations.
   dplyr::mutate(
      op.reset = Vectorize(hasReset)(op),
      op.pr = Vectorize(hasPR)(op),
      op.xe = Vectorize(hasExchange)(op),
   ) 

finals <- all.fx %>%

   group_by(instance,seed) %>%
   mutate(
      reset = sum(op.reset),
      pr = sum(op.pr),
      xe = sum(op.xe),
   ) %>%
   ungroup() %>%

   # Then compute some metrics regarding all the runs with distinct seeds.
   group_by(instance) %>%
   dplyr::filter(generation == max(generation)) %>%

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
      tmax.sd = sd(tmax),

      op.reset.mean = mean(reset),
      op.reset.sd = sd(reset),
      
      op.pr.mean = mean(pr),
      op.pr.sd = sd(pr),
      
      op.xe.mean = mean(xe),
      op.xe.sd = sd(xe)
   )

fwrite(finals, "finals.csv")

