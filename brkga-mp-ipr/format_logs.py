#!/usr/bin/env python3
#! -*- coding: utf-8 -*-

from sys import argv
from os import path

if __name__ == "__main__":
   if len(argv) != 3:
      print("Usage: %s <1:experiment ID> <2:logfile>" % argv[0])
      exit(1)

   experiment_id = argv[1]
   logfile = argv[2]

   instance = ""
   seed = ""

   flag = False
  
   with open(logfile) as fid, open("results.csv", "a") as csv:
      if csv.tell() == 0:
         csv.write("instance,seed,generation,remaining,local,elite.stdev,no.improve,cost,dist,tard,tmax,time,op\n")
      for line in fid:
         if "Instance:" in line:
            instance = path.splitext(path.basename(line))[0]
            instance = instance.replace("InstanzCPLEX_HCSRP_","")
            instance = instance.replace("InstanzVNS_HCSRP_","")
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
               if tks[-1] != 'X' and tks[-1] != 'P' and tks[-1] != 'R':
                  csv.write(",\n")
               else:
                  csv.write("\n")

            if "Evolving" in line and "generations..." in line:
               flag = True

