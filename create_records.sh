#!/bin/sh
#takes in two arguments starting index and end INDEX

#startIndex="$1"
#endIndex="$2"

if ['$1' -lt 1]
then
  '$1' = 1
fi

for ((i="$1"; i<="$2"; i++ ))
do
  pdnsutil add-record test.com r"$i" A 192.168.1.2
done
