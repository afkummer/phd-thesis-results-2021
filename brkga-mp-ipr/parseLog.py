#!/usr/bin/env python3
#! -*- coding: utf-8 -*-

import lzma
from sys import argv
from os import path

def open_log(fname:str):
   if ".xz" in fname:
      return lzma.open(fname, mode="rt")
   else:
      return open(fname)

if __name__ == "__main__":
   if len(argv) != 2:
      print("Usage: %s <1:logfile>" % argv[0])
      exit(1)

   logfile = argv[1]
   instance = ""
   seed = ""
   flag = False
  
   with open_log(logfile) as fid, open("results.csv", "a") as csv:
      if csv.tell() == 0:
         csv.write("instance,seed,generation,remaining,local,elite.stdev,no.improve,cost,dist,tard,tmax,time,op\n")
      for line in fid:
         if "Instance:" in line:
            instance = line.split()[-1].strip()
            # instance = path.splitext(path.basename(line))[0]
            # instance = instance.replace("InstanzCPLEX_HCSRP_","")
            # instance = instance.replace("InstanzVNS_HCSRP_","")
         elif "Seed:" in line:
            seed = line.split()[-1].strip()
         else:
            tks = line.split()
            if "Evolutionary process finished" in line:
               flag = False
            if len(tks) >= 9 and flag:
               if tks[0] == "Gens":
                  continue
               if tks[0] == "*":
                  tks = tks[1:]
               csv.write("%s,%s," % (instance, seed))
               csv.write(",".join(tks))
               if 'X' not in tks[-1] and 'P' not in tks[-1] and 'R' not in tks[-1]:
                  csv.write(",\n")
               else:
                  csv.write("\n")

            if "Evolving" in line and "generations..." in line:
               flag = True

