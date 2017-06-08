# works in bash, zsh and ksh93
~$ f=file.tar.bz2
~$ echo "${f##*.}"
bz2
~$ echo "${f#*.}"
tar.bz2
~$ echo "${f%.*}"
file.tar
~$ echo "${f%%.*}"
file 
:
