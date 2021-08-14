#!/usr/bin/env Rscript

require(dplyr)
require(data.table)

# Converts instance sizes (number of nodes) to the name of the
# respective instance subsets.
instanceSizeToFamily <- function(s) {
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
extractInstanceName <- function(s) {
   tks <- unlist(strsplit(s, "[_\\.]"))
   return(paste0(instanceSizeToFamily(tks[3]), tks[4]))
}

extractInstanceNames.df <- function(df, colname = "instance") {
   fvec = Vectorize(extractInstanceName)
   df <- as_tibble(df)
   return(dplyr::mutate(df, !!as.name(colname) := fvec(!!as.name(colname))))
}

extractInstanceSize <- function(s) {
   tks <- unlist(strsplit(s, "[_\\.]"))
   return(as.numeric(instanceSizeToFamily(tks[3])))
}

cat("Importing data...\n")
all <- fread("all.csv")

cat("\n\nFixing instance names...\n")
all.fx <- extractInstanceNames.df(all)

cat("\n\nWriting data back to csv...\n")
fwrite(all.fx, "all.fx.csv")
