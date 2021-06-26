#!/usr/bin/env python3
#! -*- coding: utf-8 -*-

# Support for reading XZ-compressed data.
import lzma

def openLog(fname:str):
   if ".xz" in fname:
      return lzma.open(fname, "rt")
   else:
      return open(fname, "rt")


if __name__ == "__main__":
   from sys import argv
   if len(argv) != 2:
      print("Usage: %s <1:logfile path>")
      exit(1)

   instance = ""
   seed = -1

   data = []
   optFound = False
   lb = None

   with openLog(argv[1]) as fid:
      for line in fid:
         tks = [x.strip() for x in line.split() if len(x.strip()) > 0]
         if len(tks) == 0:
            continue

         # print(line)
         # print(tks)

         if "Solution time" in line and "Iterations" in line and "Nodes" in line:
            time = tks[3]
            iters = tks[7]
            nodes = tks[10]

         if "Current MIP best bound" in line:
            lb = tks[5]

         if "integer feasible:  Objective" in line:
            ub = tks[9]

         if "MIP - Integer optimal," in line or "Integer optimal solution" in line:
            ub = tks[-1]
            optFound = True

         if "-- Instance file: " in line:
            inst = tks[-1]
            from os import path
            inst = path.basename(inst)

         if "defined initial solution with objective" in line:
            warmstart = tks[-1][:-1]

         if "Reduced MIP has" in line and "nonzeros." in line:
            rows = tks[3]
            cols = tks[5]
            nzz = tks[8]

   if optFound and lb == None:
      lb = ub

   # print("\n\n")
   # print("inst =", inst)
   # print("logfile =", argv[1])
   # print("warmstart =", warmstart)
   # print("time =", time)
   # print("iters =", iters)
   # print("nodes =", nodes)
   # print("lb =", lb)
   # print("ub =", ub)
   # print("rows =", rows)
   # print("cols =", cols)
   # print("nzz =", nzz)

   with open("all.csv", "a+") as fid:
      if fid.tell() == 0:
         fid.write("instance,logfile,cost.warmstart,time,iters,nodes,lb,ub,rows,cols,nzz\n")

      line = ",".join([inst, argv[1], warmstart, time, iters, nodes, lb, ub, rows, cols, nzz])[:-1] + "\n"
      fid.write(line)
