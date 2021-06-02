#!/usr/bin/env Rscript

require(dplyr)
require(data.table)

# This scripts is solely used to import data to the workspace.

all <- as_tibble(fread("all.csv"))
all.fx <- as_tibble(fread("all.fx.csv"))
