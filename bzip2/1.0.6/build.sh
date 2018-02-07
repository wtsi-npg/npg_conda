#!/bin/sh

set -e

make PREFIX="$PREFIX" install
make clean

make -f Makefile-libbz2_so PREFIX="$PREFIX"
cp -a libbz2.so* "$PREFIX/lib"
