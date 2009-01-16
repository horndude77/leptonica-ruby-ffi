#!/bin/sh

SCRIPT_DIR=`dirname $0`
C_SRC=$SCRIPT_DIR/c/
OBJ=$SCRIPT_DIR
if [ ! -d $OBJ ]; then
mkdir $OBJ
fi

gcc -O3 -o $OBJ/estimate_staff_parameters.o -I/home/jay/programming/github/leptonica/src/ -c $C_SRC/estimate_staff_parameters.c
#gcc -o estimate_staff_parameters estimate_staff_parameters.o /usr/lib/liblept.so.1.58

gcc --shared -llept -o $OBJ/libscore_tools.so $OBJ/*.o

