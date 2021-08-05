#!/bin/sh

set -ex

n="$CPU_COUNT"

pushd seqtk
make -j "$n"
make install BINDIR="$PREFIX"
popd
