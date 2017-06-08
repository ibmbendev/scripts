#!/bin/bash

from=$(date -d "$(echo "$1" | awk 'BEGIN { FS = "[/:]"; } { print $1" "$2" "$3" "$4":"$5":"$6 }')" +%s)
to=$(date -d "$(echo "$2" | awk 'BEGIN { FS = "[/:]"; } { print $1" "$2" "$3" "$4":"$5":"$6 }')" +%s)

while read line
do
    date=$(echo $line | awk '{ print substr($4, 2, length($4)-1) }' | awk 'BEGIN { FS = "[/:]"; } { print $1" "$2" "$3" "$4":"$5":"$6 }')
    date=$(date -d "$date" +%s)
    [[ $date -ge $from && $date -le $to ]] && echo $line
done < $3
