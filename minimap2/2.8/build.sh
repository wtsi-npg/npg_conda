#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

make -j $n

mkdir -p "$PREFIX/bin"
cp minimap2 "$PREFIX/bin/"

mkdir -p "$PREFIX/share/man/man1"
cp minimap2.1 "$PREFIX/share/man/man1/"
