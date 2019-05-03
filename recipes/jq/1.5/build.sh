#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" --disable-maintainer-mode

make -j "$n" LDFLAGS=-all-static
make install prefix="$PREFIX"
