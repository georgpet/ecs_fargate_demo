#!/bin/sh -e

const=`echo "scale=4; 60 / $1" | bc`
i=1

while sleep $const; do

 echo "$i:" 
 curl $2 &
 i=$((i+1))

done