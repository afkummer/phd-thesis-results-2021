#!/usr/bin/env Rscript

require(compiler)
invisible(enableJIT(3))

br.split <- function(str) {
   return(unlist(strsplit(basename(str), "_")))
}

br.seqid <- function(str) {
   return (br.split(str)[2])
}

br.nodes <- function(str) {
   return (br.split(str)[3])
}

br.vehicles <- function(str) {
   return (br.split(str)[4])
}

br.nsync <- function(str) {
   return (br.split(str)[5])
}

br.tw.type <- function(s) {
   return (switch(s, "1" = "F", "2" = "S", "3" = "M", "4" = "L", "5" = "A"))
}

br.tw <- function(str) {
   tw <- br.split(str)[6]
   return (br.tw.type(strsplit(tw, "\\.")[[1]][1]))
}

br.id <- function(str) {
   n <- br.nodes(str)
   off <- switch(n, "20" = 1, "50" = 6, "80" = 9)
   return (off + as.integer(br.seqid(str))-1)
}

br.desc <- function(str) {
   return (list(
      "filename" = str,
      "id" = br.id(str),
      "seqid" = br.seqid(str),
      "nodes" = br.nodes(str),
      "vehicles" = br.vehicles(str),
      "syncnodes" = br.nsync(str),
      "tw" = br.tw(str)
   ))
}

br.fixNames <- function(df) {
   return(
      dplyr::mutate(df,
         ID = Vectorize(br.id)(instance),
         nodes = Vectorize(br.nodes)(instance),
         vehicles = Vectorize(br.vehicles)(instance),
         nodes.sync = Vectorize(br.nsync)(instance),
         tw.type = Vectorize(br.tw)(instance),
      )
   )
}

