#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

make -j $n CFLAGS="-g -Wall -O2 --std=gnu89" \
     INCLUDES="-I. -I.. -I$PREFIX/include" \
     LIBS="-L$PREFIX/lib -lm -lz -lpthread -Lbwt_gen -lbwtgen"

mkdir -p "$PREFIX/bin"
cp bwa "$PREFIX/bin/"

mkdir -p "$PREFIX/share/man/man1"
cp bwa.1 "$PREFIX/share/man/man1/"
