#!/bin/bash
# dyndee.sh - update client for dyndns.org
# written entirely in bash
#
# Copyright © 2006 grulos@gmail.com
# Licenced under the terms of GNU GPL
# http://www.gnu.org/licenses/gpl.txt
#
# http://grulos.blogspot.com

# --------------->configuration<--------------- #
# If there is something you don't understand,
# read https://www.dyndns.com/developers/specs/syntax.html

user="testuser"
pass="testpass"

# dyndns|statdns|custom
system="dyndns"

# hostname="host1.dyndns.org,host2.dyndns.org..."
hostname="test.dyndns.org"

# ON|OFF|NOCHG
wildcard="OFF"

# mailexchanger|NOCHG
mx="OFF"

# YES|NO|NOCHG
backmx="OFF"

# YES|NO
offline="NO"

# set to YES for quiet mode
# YES|NO
quiet="NO"

# where is the ip saved?
# ipfile=/tmp/dyndee.ip
ipfile="$HOME/.dyndee.ip"
# ------------>end of configuration<------------ #

# if ipfile does not exist, create it
[[ -w "$ipfile" && -r "$ipfile" ]] || >"$ipfile"

[ "$quiet" == "YES" ] && q=">/dev/null"

# get ip address
# <?php echo $_SERVER['REMOTE_ADDR']; ?>
exec 3<>/dev/tcp/metawire.org/80
printf "%s\n" "GET /~inode/ip.php">&3
read -u 3 myip
exec 3>&-;
IFS="."
set -- $myip
[[ "$#" == "4" ]] || ( echo "Are you offline?" && exit 1 )
IFS=$'\040\t\n'

[ "$myip" == "$(<$ipfile)" ] && 
eval echo "No need to update"$q && 
exit 0

# base64 encoding of user:pass
str="$user:$pass"

# Generate ascii string
for ((i=0; i<128; i++)); do
ascii=$ascii$(echo -en $(printf "%s%o" "\\" "$i"))
done

# convert decimal to 8-bit binary
for ((i=0; i<${#str}; i++)); do
j="${str:$i:1}"
t="${ascii%%$j*}"
t=$((${#t}+2))
unset d2b
while ((t>0)); do
d2b="$((t%2))$d2b"
t="$((t/2))"
done
bit8="$bit8$(printf "%08d" "$d2b")"
done

# pad 0's if needed
pad0=$(($((6-${#bit8}%6))%6))
((pad0)) && bit8=$bit8$(printf "%0$((pad0))d" 0)

uascii="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

# 8-bit string divided to 6-bit
# its decimal value is used as an index to uascii
for ((i=0; i<${#bit8}; i+=6)); do
bit6="${bit8:i:6}"
encstr="$encstr${uascii:$((2#${bit8:i:6})):1}"
done

eqpad="=="
encstr="$encstr${eqpad:0:$((pad0/2))}"

# now send it all to dyndns
exec 3<>/dev/tcp/members.dyndns.org/80
printf "%s\n\n" "GET /nic/update?system=$system&hostname=$hostname&myip=\
$myip&wildcard=$wildcard&mx=$mx&backmx=$backmx&offline=$offline HTTP/1.0
User-Agent: dyndee/1.0 grulos@gmail.com
Host: members.dyndns.org:80
Authorization: Basic $encstr">&3

read -a status<&3

case "${status[1]}" in
"200")  ;; # everything ok
"401")  echo "Unauthorized. Please check your username and password."
exit 1;;
*    )  echo "error: ${status[@]}"
exit 2;;
esac

while read header; do
[ "$header" == $'\r' ] && break
done<&3

read -n 255 -a body<&3
case "${body[0]}" in
"badsys"   )   echo "system=$system is invalid."
echo "valid options are: dyndns, statdns, custom"
exit 3;;
"badagent" )   echo "User agent has been blocked"
echo "please report this to grulos@gmail.com"
exit 4;;
"badauth"  )   echo "Username and/or password are incorrect"
exit 5;;
"!donator" )   echo "You are not a credited user"
exit 6;;
"nochg"    )   eval echo "Nothing Changed"$q
echo "$myip">"$ipfile";;
"good"     )   eval echo "Updated ${body[@]:1}"$q
echo "$myip">"$ipfile";;
"notfqdn"  )   echo "hostname $hostname is not a fully-qualified domain name"
exit 7;;
"nohost"   )   echo "hostname $hostname does not exist!"
exit 8;;
"!yours"   )   echo "hostname $hostname exists but it's not yours"
exit 9;;
"numhost"  )   echo "Too many or too few hosts found"
exit 10;;
"abuse"    )   echo "Woops! You have been blocked for update abuse"
exit 11;;
"dnserr"   )   echo "DNS error encountered"
echo "please report this to support@dyndns.com"
exit 12;;
"911"      )   echo "dyndns.org is experiencing problems"
echo "please wait a few minutes before updating again"
exit 13;;
*          )   echo "Unknown error: ${body[@]}"
echo "Please report this to grulos@gmail.com"
exit 14;;
esac

exec 3>&-
