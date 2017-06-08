
#!/bin/bash
#
# renumdir.sh: renames dirs to sequentially
# numbered ones starting from 00001 
# ex. 00001 00002 00003 00004 etc.
#
# questions? suggestions? comments?
# grulosΨgmail.com
#

cd $1 || exit 1
typeset -a files=(*)
typeset -i j=1

for i in "${files[@]}"; do

   if [ -d "$i" ]; then
   # infinite loop until we find the next
   # numbered dir we are going to use

      while true; do
         fname=0000$j;

         # we want only 5 digits
         # why didn't i just use printf "%05d" ? :P
         fname=${fname:$(( ${#fname}-5 ))};

         # check if the dir is already numbered
         # in that case move to next dir
         [ "$fname" == "$i" ] && j=$(( j+1 )) && break

         if [ -d "$fname" ]; then
            j=$(( j+1 ));
            continue;
         else
            mv -- "$i" "$fname"
            j=1
            break
         fi
      done
   fi
done

