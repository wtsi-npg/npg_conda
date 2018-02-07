#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

prefix="$PREFIX" ./configure 
make -j $n
make install
