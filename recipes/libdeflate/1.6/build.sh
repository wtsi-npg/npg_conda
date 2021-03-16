#!/bin/sh

set -ex

n="$CPU_COUNT"

make -j $n
make install PREFIX="$PREFIX"

