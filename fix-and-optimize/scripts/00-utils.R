#!/usr/bin/env Rscript

require(dplyr)
require(data.table)

# Utilitary functions for translating instances files from
# Mankowska et al. (2014) dataset to the naming convention
# used in their article.

# Converts instance sizes (number of nodes) to the name of the
# respective instance subsets.
instance_size_to_subset <- function(s) {
   s <- as.character(s)
   if (s == "10") {
      return("A")
   } else if (s == "25") {
      return("B")
   } else if (s == "50") {
      return("C")
   } else if (s == "75") {
      return("D")
   } else if (s == "100") {
      return("E")
   } else if (s == "200") {
      return("F")
   } else if (s == "300") {
      return("G")
   }
   cat("Unknown instance subset: ", s, "\n")
}

# Takes an entire path, extract the information regarding the
# instance, and returns the adequate name according to Mankowska's
# naming convention.
format_mk_instance_name <- function(s) {
   tks <- unlist(strsplit(s, "[_\\.]"))
   return(paste0(instance_size_to_subset(tks[3]), tks[4]))
}

# Changes the instance names from filepath to (subset)(Id) format.
format_mk_instance_name_df <- function(df, colname = "instance") {
   fvec <- Vectorize(format_mk_instance_name)
   df <- as_tibble(df)
   return(dplyr::mutate(df, !!as.name(colname) := fvec(!!as.name(colname))))
}
