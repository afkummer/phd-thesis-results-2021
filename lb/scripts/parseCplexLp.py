#!/usr/bin/env python3
#! -*- coding: utf-8 -*-

if __name__ == "__main__":
   from sys import argv
   if len(argv) != 2:
      print("Usage: %s <1:logfile path>")
      exit(1)

   instance = ""
   lb = "NA"
   time = "NA"
   iters = "NA"

   with open(argv[1]) as fid:
      for line in fid:
         tks = [x.strip() for x in line.split() if len(x.strip()) > 0]
         if len(tks) == 0:
            continue

         if "Solution time =" in line:
            time = tks[3]
            iters = tks[7]

         if "-- Instance file: " in line:
            instance = tks[-1]
            from os import path
            instance = path.basename(instance)

         if "Optimal:  Objective = " in line:
            lb = tks[-1]



   if False:
      print("\n\n")
      print("inst =", instance)
      print("logfile =", argv[1])
      print("time =", time)
      print("iters =", iters)
      print("lb =", lb)

   if True:
      with open("cplex.csv", "a+") as fid:
         if fid.tell() == 0:
            fid.write("instance,logfile,time,iters,lb\n")
         fid.write(instance + "," + argv[1] + "," + time + "," + iters + "," + lb + "\n")



