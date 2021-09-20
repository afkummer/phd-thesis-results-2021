#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(compiler)

invisible(enableJIT(3))

# Checks for command line arguments.
args <- commandArgs(trailingOnly = T)

if (length(args) != 3) {
   cat("Usage: ./03-algo-comparator.R <rg.csv> <go.csv> <ro.csv>\n")
   cat("This script only works with pre-processed data with 01-fix_names.R.\n")
   q(status = 1)
}

rg_file <- args[1]
go_file <- args[2]
ro_file <- args[3]

cat("------------------------------------\n")
cat("--- Algorithm comparator for F&O ---\n")
cat("------------------------------------\n")

cat("(1/6) Reading data...\n")
rg <- fread(rg_file) %>%
   group_by(instance, seed) %>%
   dplyr::filter(iter == max(iter)) %>%
   mutate(exp = factor("random-guided"))

go <- fread(go_file) %>%
   group_by(instance, seed) %>%
   dplyr::filter(iter == max(iter)) %>%
   mutate(exp = factor("guided-only"))

ro <- fread(ro_file) %>%
   group_by(instance, seed) %>%
   dplyr::filter(iter == max(iter)) %>%
   mutate(exp = factor("random-only"))

cat("(2/6) Merging data...\n")
all <- bind_rows(rg, ro, go) %>% dplyr::filter(!subset %in% c("G", "F"))
levels(all$exp) <- list("Guided+Random" = "random-guided", "Guided only" = "guided-only", "Random only" = "random-only")
cat("Merged datasets contain", nrow(all), "rows and", ncol(all), "columns.\n")

# 
# Average results per family, all seeds.
#
plt <- ggplot(all, aes(subset, obj, fill = exp)) +
   geom_boxplot(outlier.shape = 3, outlier.alpha = 0.3) +
   xlab("Instance subset") +
   ylab("Solution value (avg)") +
   theme_bw() +
   labs(fill = "Algorithm") +
   theme(
      legend.position = c(0.22, 0.88),
      legend.background = element_rect(fill = "white", color = "black")
   )

cat("(3/6) Plotting cost boxplot per subset...\n")
ggsave("../out/algo-compare-obj.pdf", plt, width = 5)

#
# Average time per family, all seeds.
#
levels(all$exp) <- list("Random only" = "random-only", "Guided+Random" = "random-guided", "Guided only" = "guided-only")

plt <- ggplot(all, aes(subset, time, fill = exp)) +
   geom_boxplot(outlier.shape = 3, outlier.alpha = 0.3) +
   xlab("Instance subset") +
   ylab("Average runtime (sec)") +
   theme_bw() +
   labs(fill = "Algorithm") +
   theme(
      legend.position = c(0.22, 0.88),
      legend.background = element_rect(fill = "white", color = "black")
   )

cat("(4/6) Plotting runtime boxplot per subset...\n")
ggsave("../out/algo-compare-time.pdf", plt, width = 5)

#
# Compute the statistics for each decomposition scheme, per instance.
#

# Re-read all the results. In this analysis, we need 
# information for each iteration of the matheuristic.
rg_full <- fread(rg_file) %>% dplyr::filter(!subset %in% c("G", "F"))

# Compute the statistics per instance.
stat_per_instance <- rg_full %>%
   group_by(instance, seed) %>%
   arrange(iter, .by_group = T) %>%
   mutate(
      obj.previous = dplyr::lag(x=obj, default=first(obj[method=="initial"]))
   ) %>%
   mutate(impr = obj.previous - obj) %>%
   ungroup() %>%
   group_by(instance) %>%
   summarize(
      subset = first(subset),
      iid = first(iid),

      decomp.r.total = length(method[method == "random"]),
      decomp.g.total = length(method[method == "guided"]),
      decomp.r.impr = length(method[method == "random" & impr >= 0.001]),
      decomp.g.impr = length(method[method == "guided" & impr >= 0.001]),

      random.obj.impr.mean = mean(impr[method == "random" & impr >= 0.001]),
      random.obj.impr.sd = sd(impr[method == "random" & impr >= 0.001]),

      guided.obj.impr.mean = mean(impr[method == "guided" & impr >= 0.001]),
      guided.obj.impr.sd = sd(impr[method == "guided" & impr >= 0.001])
   ) %>%
   arrange(subset, iid)

cat("(5/6) Writing decomposition statistics per instance...\n")
fwrite(stat_per_instance, "../out/algo-compare-stat-per-instance.csv")

#
# Compute the statistics for each decomposition scheme, per subset.
#

# Compute the statistics per instance.
stat_per_subset <- rg_full %>%
   group_by(instance, seed) %>%
   arrange(iter, .by_group = T) %>%
   mutate(
      obj.previous = dplyr::lag(x = obj, default = first(obj[method == "initial"]))
   ) %>%
   mutate(impr = obj.previous - obj) %>%
   ungroup() %>%

   group_by(subset) %>%
   summarize(
      decomp.r.total = length(method[method == "random"]),
      decomp.g.total = length(method[method == "guided"]),
      decomp.r.impr = length(method[method == "random" & impr >= 0.001]),
      decomp.g.impr = length(method[method == "guided" & impr >= 0.001]),
      
      random.obj.impr.mean = mean(impr[method == "random" & impr >= 0.001]),
      random.obj.impr.sd = sd(impr[method == "random" & impr >= 0.001]),

      guided.obj.impr.mean = mean(impr[method == "guided" & impr >= 0.001]),
      guided.obj.impr.sd = sd(impr[method == "guided" & impr >= 0.001])
   ) %>%
   arrange(subset)

cat("(6/6) Writing decomposition statistics per instance subset...\n")
fwrite(stat_per_subset, "../out/algo-compare-stat-per-subset.csv")

cat("Done!\n")