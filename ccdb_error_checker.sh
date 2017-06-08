#!/bin/bash
awk -vDate=`date -d'now-2 hours' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print Date FS $4}' access.log
awk -vDate=`date -d'now-2 hours' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $1}' access.log | sort  |uniq -c |sort -n | tail
awk -vDate=`date -d'now-4 hours' +[%d/%b/%Y:%H:%M:%S` -vDate2=`date -d'now-2 hours' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date && $4 < Date2) print Date FS Date2 FS $4}' access.log
awk -vDate=`date -d '13:20' +[%d/%b/%Y:%H:%M:%S` -vDate2=`date -d'13:30' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date && $4 < Date2) print $0}' access.log 
awk -vDate=`date -d '13:20' +[%d/%b/%Y:%H:%M:%S` -vDate2=`date -d'13:30' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date && $4 < Date2) print $1}' access.log | sort  |uniq -c |sort -n | tail
awk -vDate=`date -d'now-2 hours' +[%d/%b/%Y:%H:%M:%S` '$4 > Date {print Date, $0}' access_log


LOG=sample.log
 awk '$1 >=from && $1= to {print}' from="03:06" to="03:09" sample.log  | more

