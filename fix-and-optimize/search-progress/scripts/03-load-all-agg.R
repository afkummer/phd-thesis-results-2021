#!/usr/bin/env Rscript

require(dplyr)
require(data.table)

# First read all results for each one of the experiments to memory.
all.rg <- fread("random-guided/all.fx.csv") %>% as_tibble() %>% mutate(exp="R+G")
all.ro <- fread("random-only/all.fx.csv") %>% as_tibble() %>% mutate(exp="R")
all.go <- fread("guided-only/all.fx.csv") %>% as_tibble() %>% mutate(exp="G")

all <- rbind(all.rg, all.ro, all.go)
all$exp <- as.factor(all$exp)

plotInstanceProgress <- function(instance.name, iter.beg=0, iter.end=99999) {
   cat("Printing progress plot for instance ", instance.name, "\n")
   tmp <- all %>% 
      dplyr::filter(instance == instance.name & iter >= iter.beg & iter < iter.end) %>%
      group_by(iter, exp) %>%
      mutate(
         obj.mean = mean(obj),
         obj.sd = sd(obj),
         obj.min = min(obj), 
         obj.max = max(obj)
      ) %>%
      ungroup() 

   cat("Preprocessed data:\n")
   print(head(tmp))

   tmp$`Algorithm` <- tmp$exp

   plt <- ggplot(tmp, aes(iter, obj.mean, color=`Algorithm`, fill=`Algorithm`)) + 
      geom_line() + 
      geom_ribbon(aes(ymin=obj.min, ymax=obj.max), alpha=0.05, linetype=3) +
      geom_hline(yintercept=min(tmp$obj), linetype=2) +
      theme_bw(12) + 
      xlab("Iteration") +
      ylab("Solution cost") 

   dev.new()
   print(plt)
   return(plt)
}

