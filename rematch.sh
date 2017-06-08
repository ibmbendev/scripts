#!/bin/bash
exec 4<>/dev/tcp/rss.freshmeat.net/80
printf "%s\n" "GET /freshmeat/feeds/fm-releases-global">&4
while read line; do
[[ "$line" =~ "<title>(.*)</title>" ]] && 
printf "%s\n" "${BASH_REMATCH[1]}"
done<&4
exec 4>&-


