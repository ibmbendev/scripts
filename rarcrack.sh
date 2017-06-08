#!/bin/bash
wordfile=/usr/share/dict/words
xrar=/usr/bin/unrar
[ -x "$xrar" ] || exit 1
[ -r "$wordfile" ] || exit 1
[ -r "$1" ] || exit 1
trap 'printf "\n%s\n" "caught signal" && exit 1' 2
try=('|' '/' '-' '\')
i=1
while read line; do
   printf "\r%-$((${#pline}+10))s\r%s" "${try[$((i%4))]} trying $line"
   "$xrar" e -p"$line" "$1">/dev/null 2>&1 &&
   printf "\r%-$((${#line}+10))s\n" "password: $line" && exit 0
   ((i++))
   pline=$line
done<$wordfile
printf "%s\n" "tried $i passwords but no luck!"
