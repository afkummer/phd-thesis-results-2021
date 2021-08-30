#!/usr/bin/env python3
#! -*- coding: utf-8 -*-

if __name__ == "__main__":
   from sys import argv
   if len(argv) != 2:
      print("Usage: %s <1:logfile path>")
      exit(1)

   instance = ""
   optFound = False
   lb = None
   status = "OOM-PRESOLVE"
   lb = "NA"
   ub = "NA"
   time = "NA"
   iters = "NA"
   nodes = "NA"
   rows = "NA"

   with open(argv[1]) as fid:
      for line in fid:
         tks = [x.strip() for x in line.split() if len(x.strip()) > 0]
         if len(tks) == 0:
            continue

         if "Solution time" in line and "Iterations" in line and "Nodes" in line:
            time = tks[3]
            iters = tks[7]
            nodes = tks[10]

         if "Current MIP best bound" in line:
            lb = tks[5]

         if "integer feasible:  Objective" in line:
            ub = tks[9]
            status = "TL"

         if "Elapsed time =" in line:
            time = tks[3]

         if "Time limit exceeded, no integer solution." in line:
            status = "TL"

         if "MIP - Integer optimal," in line or "Integer optimal solution" in line:
            ub = tks[-1]
            optFound = True
            status = "OPT"

         if "-- Instance file: " in line:
            instance = tks[-1]
            from os import path
            instance = path.basename(instance)

         if "Reduced MIP has" in line and "nonzeros." in line:
            rows = tks[3]
            cols = tks[5]
            nzz = tks[8]

         # print("tks =" + str(tks))
         # print("line =", line.strip())
         # print("lb =", lb)
         # print("\n")

         if tks[0].startswith('*') or tks[0].isnumeric():
            status = "OOM-BC"

            if tks[0].isnumeric():
               if len(tks) == 6:
                  nodes = tks[0]
                  iters = tks[-1]
                  lb = tks[-2]
               elif len(tks) == 8:
                  nodes = tks[0]
                  iters = tks[-2]
                  lb = tks[-3]
                  ub = tks[-4]
               elif len(tks) == 7 and "Cuts:" in line:
                  nodes = tks[0]
                  iters = tks[-1]
            elif tks[0].startswith('*'):
               tks = [x.strip() for x in line.replace("+", " ").split() if len(x.strip()) > 0]
               lb = tks[-2]
               ub = tks[-3]
               nodes = tks[0][1:]

   # Indicates failure to build the model.
   if rows == "NA":
      status="FAIL"
      cols = "NA"
      nzz = "NA"


   if optFound:
      lb = ub

   if False:
      print("\n\n")
      print("inst =", instance)
      print("logfile =", argv[1])
      print("status =", status)
      print("time =", time)
      print("iters =", iters)
      print("nodes =", nodes)
      print("lb =", lb)
      print("ub =", ub)
      print("rows =", rows)
      print("cols =", cols)
      print("nzz =", nzz)

   if True:
      with open("cplex.csv", "a+") as fid:
         if fid.tell() == 0:
            fid.write("instance,logfile,status,time,iters,nodes,lb,ub,rows,cols,nzz\n")
         fid.write(instance + "," + argv[1] + "," + status + "," + time + "," + iters + "," + nodes + "," + lb + "," + ub + "," + rows + "," + cols + "," + nzz + "\n")



