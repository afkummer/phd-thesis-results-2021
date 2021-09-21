#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(compiler)
library(reshape2)

invisible(enableJIT(3))

# Checks for command line arguments.
args <- commandArgs(trailingOnly = T)

cat("----------------------------------\n")
cat("--- Solution method comparator ---\n")
cat("----------------------------------\n")

cat("(1/5) Reading data...\n")
others <- fread("../raw-csv/other-methods.csv")
ga <- fread("../out/brkga-mp-ipr.means.csv") %>% 
   dplyr::select(instance, subset, iid, time.mean, cost.min) %>% 
   dplyr::rename(brkga.mp.ipr = cost.min, brkga.mp.ipr.time = time.mean)

cat("(2/5) Merging data...\n")
all <- inner_join(others, ga, by=c("instance", "iid", "subset")) %>%
   mutate(
      instance = factor(instance),
      subset = factor(subset),
      iid = factor(iid)
   )

cat("(3/5) Melting entire dataset...\n")
all.obj <- dplyr::select(all, -tm.mk, -tm.mk.adj, -tm.lf, -tm.lf.adj, -tm.matheur, -tm.brkga, -brkga.mp.ipr.time)
m <- melt(dplyr::select(all.obj, -iid), id.vars = c("instance", "subset"))

levels(m$variable) <- list("Mankowska et al. (2014)" = "mk", "Lasfargeas et al. (2019)" = "lf", "F&O" = "matheur", "BRKGA" = "brkga", "BRKGA-MP-IPR" = "brkga.mp.ipr")

cat("(4/5) Generating method plot for objective value...\n")
plt <- ggplot(dplyr::filter(m, subset != "A"), aes(x = subset, y = value, fill = variable)) +
   geom_boxplot(outlier.shape = 2) +
   theme_bw(base_size = 16) +
   xlab("Instance subset") +
   ylab("Solution value (log)") +
   labs(fill = "Source") +
   theme(legend.position = c(0.14, 0.85), legend.background = element_rect(fill = "white", color = "black")) +
   scale_y_log10()

cat("(5/5) Writing plot to ../out/all-methods-obj.pdf...\n")
ggsave("../out/all-methods-obj.pdf", plt, width = 12, height = 8)

cat("Done!\n")
