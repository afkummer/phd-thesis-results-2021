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

   inst = ""
   ub = "inf"
   patients = ""
   vehi = ""
   expanded = ""

   cost = ""
   timeAll = ""

   opt = ""
   rootObjRmp = ""
   rootTime = ""
   bcpNodes = ""
   bestBound = ""

   with openLog(argv[1]) as fid:
      for line in fid:
         tks = [x.strip() for x in line.split() if len(x.strip()) > 0]

         if len(tks) == 0:
            continue

         if tks[0] == 'Instance:':
            inst = tks[1]
         if tks[0] == 'UB:':
            ub = tks[1]

         if "Number of patients:" in line:
            patients = tks[-1]
         if "Number of vehicles:" in line:
            vehi = tks[-1]
         if "Expanded number of nodes:" in line:
            expanded = tks[-1]

         if "Time consumed" in line:
            timeAll = tks[-2]
         if "Solution value:" in line:
            cost = tks[-1]

         if "statistics:" in line:
            opt = tks[3]
            rootObjRmp = tks[7]
            rootTime = tks[9]
            bcpNodes = tks[11]
            bestBound = tks[13]

   with open("results.csv", "a+") as fid:
      if fid.tell() == 0:
         fid.write("instance,ub,patients,vehi,patients.exp,cost,time.build.solve,opt.found,cost.root.rmp,time.root,bcp.nodes,cost.bestbound\n")

      fid.write(inst + "," + ub + "," + patients + "," + vehi + "," + expanded + ",")
      fid.write(cost + "," + timeAll + "," + opt + "," + rootObjRmp + "," + rootTime + ",")
      fid.write(bcpNodes + "," + bestBound + "\n")