#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX"

make -j "$n"
make check
make install prefix="$PREFIX"

