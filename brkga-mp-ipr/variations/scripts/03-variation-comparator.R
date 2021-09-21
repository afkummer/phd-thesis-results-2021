#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)
library(reshape2)
library(compiler)
library(data.table)

invisible(enableJIT(3))

#
# First loads all the data.
#
cat("(1/8) Loading datasets...\n")
brkga <- fread("../out/brkga.fixed.csv") %>%
   dplyr::filter(subset %in% c("E", "F", "G")) %>%
   mutate(algo = "brkga")

def <- fread("../../out/brkga-mp-ipr.fixed.csv") %>%
   dplyr::filter(subset %in% c("E", "F", "G")) %>%
   mutate(algo = "default")

noipr <- fread("../out/no-ipr.fixed.csv") %>%
   dplyr::filter(subset %in% c("E", "F", "G")) %>%
   mutate(algo = "noipr")

noisland <- fread("../out/no-island.fixed.csv") %>%
   dplyr::filter(subset %in% c("E", "F", "G")) %>%
   mutate(algo = "noisland")

onlymp <- fread("../out/only-mp.fixed.csv") %>%
   dplyr::filter(subset %in% c("E", "F", "G")) %>%
   mutate(algo = "onlymp")

#
# Binds all the rows to run some plots.
#
cat("\n(2/8) Binding all data together...\n")
all <- bind_rows(brkga, def, noipr, noisland, onlymp) %>%
   mutate(
      subset = factor(subset),
      algo = factor(algo)
   )
cat("Combined dataset has", nrow(all), "rows.\n")

#
# Plot the average obj/time per subset, considering all seeds.
#
all.last <- all %>%
   group_by(instance, seed, algo) %>%
   dplyr::filter(generation >= max(generation)) %>%
   ungroup()
cat("Dataset with final results has", nrow(all.last), "rows.\n")

levels(all.last$algo) <- list(
   "BRKGA-MP-IPR" = "default",
   "BRKGA-MP-IPR w/o IPR" = "noipr", 
   "BRKGA-MP-IPR w/o island" = "noisland", 
   "BRKGA-MP only" = "onlymp",
   "BRKGA" = "brkga"
)

plt <- ggplot(all.last, aes(x = subset, y = cost, fill = algo)) +
   geom_boxplot() +
   theme_bw(base_size = 16) +
   xlab("Instance subset") +
   ylab("Solution value (avg, all seeds)") +
   labs(fill = "Algorithm") +
   theme(
      legend.position = c(0.3, 0.85),
      legend.background = element_rect(fill = "white", color = "black")
   )

cat("\n(3/8) Plotting obj value boxplot for all seeds...\n")
ggsave("../out/variations-obj-allseeds.pdf", plt, width = 6)

plt <- ggplot(all.last, aes(x = subset, y = time, fill = algo)) +
   geom_boxplot() +
   theme_bw(base_size = 16) +
   xlab("Instance subset") +
   ylab("Average runtime in sec (avg, all seeds)") +
   labs(fill = "Algorithm") +
   theme(
      legend.position = c(0.3, 0.85),
      legend.background = element_rect(fill = "white", color = "black")
   )

cat("\n(4/8) Plotting runtime value boxplot for all seeds...\n")
ggsave("../out/variations-time-allseeds.pdf", plt, width = 6)

#
# Plot the average obj/time per subset, considering the best seeds.
#
all.best <- all %>%
   group_by(instance, algo) %>%
   dplyr::filter(cost <= min(cost)) %>%
   dplyr::filter(row_number()==1) %>%
   ungroup()
cat("Dataset with final results has", nrow(all.last), "rows.\n")

levels(all.best$algo) <- list(
   "BRKGA-MP-IPR" = "default",
   "BRKGA-MP-IPR w/o IPR" = "noipr",
   "BRKGA-MP-IPR w/o island" = "noisland",
   "BRKGA-MP only" = "onlymp",
   "BRKGA" = "brkga"
)

plt <- ggplot(all.best, aes(x = subset, y = cost, fill = algo)) +
   geom_boxplot() +
   theme_bw(base_size = 16) +
   xlab("Instance subset") +
   ylab("Solution value (avg, best seeds)") +
   labs(fill = "Algorithm") +
   theme(
      legend.position = c(0.3, 0.85),
      legend.background = element_rect(fill = "white", color = "black")
   )

cat("\n(5/8) Plotting obj value boxplot for best seeds...\n")
ggsave("../out/variations-obj-bestseeds.pdf", plt, width = 6)

plt <- ggplot(all.best, aes(x = subset, y = time, fill = algo)) +
   geom_boxplot() +
   theme_bw(base_size = 16) +
   xlab("Instance subset") +
   ylab("Average runtime in sec (avg, best seeds)") +
   labs(fill = "Algorithm") +
   theme(
      legend.position = c(0.3, 0.85),
      legend.background = element_rect(fill = "white", color = "black")
   )

cat("\n(6/8) Plotting runtime value boxplot for best seeds...\n")
ggsave("../out/variations-time-bestseeds.pdf", plt, width = 6)

#
# Compares if BRKGA-MP-IPR is statistically different of the algorithm without IPR
#

cat("\n\n(7/8) Testing if BRKGA-MP-IPR is statistically different than BRKGA-MP-IPR w/o IPR\n")
def.last <- def %>%
   group_by(instance, seed) %>%
   dplyr::filter(generation >= max(generation)) %>%
   dplyr::filter(row_number()==1) %>%
   ungroup()%>%
   arrange(instance, seed)

noipr.last <- noipr %>%
   group_by(instance, seed) %>%
   dplyr::filter(generation >= max(generation)) %>%
   dplyr::filter(row_number()==1) %>%
   ungroup() %>%
   arrange(instance, seed)

# Sanity checks.
commons <- inner_join(def.last, noipr.last, by=c("instance","seed")) %>% select(instance, seed)
def.last <- inner_join(def.last, commons, by=c("instance", "seed"))
noipr.last <- inner_join(noipr.last, commons, by=c("instance", "seed"))
stopifnot(nrow(def.last) == nrow(noipr.last))

x <- def.last$cost
y <- noipr.last$cost
print(wilcox.test(x=x, y=y, paired=T))

#
# Compares if BRKGA-MP-IPR without islands is statistically equal to BRKGA.
#

cat("\n\n(8/8) Testing if BRKGA is statistically different than BRKGA-MP-IPR w/o multiple islands\n")
brkga.last <- brkga %>%
   group_by(instance, seed) %>%
   dplyr::filter(generation >= max(generation)) %>%
   dplyr::filter(row_number()==1) %>%
   ungroup()%>%
   arrange(instance, seed)

noisland.last <- noisland %>%
   group_by(instance, seed) %>%
   dplyr::filter(generation >= max(generation)) %>%
   dplyr::filter(row_number()==1) %>%
   ungroup() %>%
   arrange(instance, seed)

commons <- inner_join(brkga.last, noisland.last, by=c("instance","seed")) %>% select(instance, seed)
brkga.last <- inner_join(brkga.last, commons, by=c("instance", "seed"))
noisland.last <- inner_join(noisland.last, commons, by=c("instance", "seed"))

# Some more sanity checks.
stopifnot(nrow(brkga.last) == nrow(noisland.last))

x <- brkga.last$cost
y <- noisland.last$cost
print(wilcox.test(x=x, y=y, paired=T))

cat("Done!\n")
