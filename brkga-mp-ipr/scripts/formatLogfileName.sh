#!/bin/bash 

if [ $# -ne 1 ]; then
   echo "Usage: $0 <input file>"
   exit 1
fi

echo "Formatting name of '$1'"

path="$(xzcat $1 | grep 'Instance: ' | cut -d ' ' -f 2)"
file="$(basename $path .txt)"
printf "   Instance path: %s\n" $path
printf "   Basename: %s\n" $file

seed="$(xzcat $1 | grep 'Seed: ' | cut -d ' ' -f 2)"
printf "   Seed: %s\n" $seed

newname="${file}-${seed}.log.xz"
echo "Moving $1 to $newname"
mv $1 $newname

