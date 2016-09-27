#!/bin/sh
#takes in two arguments starting index and end INDEX

startIndex = "$1"
endIndex = "$2"

if [$startIndex -lt 1]
then
  $startIndex = 1
fi

for ((i="$startIndex"; i<="$endIndex"; i++ ))
do
  pdnsutil add-record test.com r"$i" A 192.168.1.2
done
