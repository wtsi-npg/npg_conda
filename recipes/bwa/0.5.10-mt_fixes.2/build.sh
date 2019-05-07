#!/bin/sh

set -ex

n="$CPU_COUNT"

make -j "$n" AR="$AR" CC="$GCC" \
     CFLAGS="-g -Wall -O2 --std=gnu89" \
     INCLUDES="-I. -I.. -I$PREFIX/include" \
     LIBS="-L$PREFIX/lib -lm -lz -lpthread -Lbwt_gen -lbwtgen"

mkdir -p "$PREFIX/bin"
cp bwa "$PREFIX/bin/"

mkdir -p "$PREFIX/share/man/man1"
cp bwa.1 "$PREFIX/share/man/man1/"
