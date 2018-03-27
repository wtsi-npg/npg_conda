#!/bin/sh

set -e

n=$CPU_COUNT

./bootstrap.sh --prefix="$PREFIX" 

./b2 -j $n --prefix="$PREFIX" --without-mpi install
