#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

cd source

make -j $n STAR STARlong
make install

mkdir -p "$PREFIX/bin"
cp ../bin/STAR "$PREFIX/bin"
cp ../bin/STARlong "$PREFIX/bin"
