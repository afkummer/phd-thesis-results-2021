#!/bin/bash 

if [ $# -ne 1 ]; then
   exit 1
fi

echo "Formatting name of '$1'"

path="$(cat $1 | grep 'Instance file: ' | cut -d ' ' -f 4)"
file="$(basename $path .txt)"
printf "   Instance path: %s\n" $path
printf "   Basename: %s\n" $file

newname="$(dirname $1)/${file}.log"
echo "Moving $1 to $newname"
git mv $1 $newname

