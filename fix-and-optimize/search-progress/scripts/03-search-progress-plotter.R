#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(compiler)

invisible(enableJIT(3))

# Checks for command line arguments.
args <- commandArgs(trailingOnly = T)

if (length(args) != 6) {
   cat("Usage: ./03-algo-comparator.R <rg.csv> <go.csv> <ro.csv> <instance> <min-iter> <max-iter>\n")
   cat("This script only works with pre-processed data with 01-fix_names.R.\n")
   q(status = 1)
}

rg_file <- args[1]
go_file <- args[2]
ro_file <- args[3]

iname <- args[4]
iters.min <- as.integer(args[5])
iters.max <- as.integer(args[6])

cat("---------------------------------------\n")
cat("--- Search progress plotter for F&O ---\n")
cat("---------------------------------------\n")

cat("(1/3) Reading data...\n")
rg <- fread(rg_file) %>%
   group_by(instance, seed) %>%
   mutate(exp = factor("random-guided"))

go <- fread(go_file) %>%
   group_by(instance, seed) %>%
   mutate(exp = factor("guided-only"))

ro <- fread(ro_file) %>%
   group_by(instance, seed) %>%
   mutate(exp = factor("random-only"))

cat("(2/3) Merging data...\n")
all <- bind_rows(rg, ro, go) %>% dplyr::filter(!subset %in% c("G", "F"))
levels(all$exp) <- list("Guided+Random" = "random-guided", "Guided only" = "guided-only", "Random only" = "random-only")
cat("Merged datasets contain", nrow(all), "rows and", ncol(all), "columns.\n")

#
# Generate the instance plot.
#

tmp <- all %>%
   dplyr::filter(instance == iname & iter >= iters.min & iter < iters.max) %>%
   group_by(iter, exp) %>%
   mutate(
      obj.mean = mean(obj),
      obj.sd = sd(obj),
      obj.min = min(obj),
      obj.max = max(obj)
   ) %>%
   ungroup()

# I have no idea how to rename the legend without duplicating
# it. Seems like ggplot2 generates distict legends for `color`
# attributes and `fill` attributes.
tmp$`Algorithm` <- tmp$exp

plt <- ggplot(tmp, aes(iter, obj.mean, color = Algorithm, fill = Algorithm)) +
   geom_line() +
   geom_ribbon(aes(ymin = obj.min, ymax = obj.max), alpha = 0.08, linetype = 3) +
   geom_hline(yintercept = min(tmp$obj), linetype = 2) +
   theme_bw(16) +
   xlab("Iteration") +
   ylab("Solution cost") +
   labs(fill="Algorithm") +
   theme(
      legend.position = c(0.9, 0.88),
      legend.background = element_rect(fill = "white", color = "black")
   )

cat("(3/3) Plotting search progress for", iname, "from iter", iters.min, "to", iters.max, "\b...\n")
out_name <- paste0("../out/search-progress-", iname, ".pdf")
ggsave(out_name, plt, width = 12)
cat("Plot written to", out_name, "\b.\n")

cat("Done!\n")