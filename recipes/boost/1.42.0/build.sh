#!/bin/sh

set -e

n=$CPU_COUNT

./bootstrap.sh --prefix="$PREFIX" 

./bjam -j $n --prefix="$PREFIX" --without-mpi -q install
