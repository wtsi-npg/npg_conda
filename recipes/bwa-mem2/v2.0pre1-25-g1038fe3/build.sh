#!/bin/bash

set -ex
PVERSION=$(git describe --tags --always)
CPPFLAGS="-I$PREFIX/include -DPACKAGE_VERSION='"'"'$PVERSION'"'"'" LDFLAGS="-L$PREFIX/lib" make -j $CPU_COUNT multi

mkdir -p "$PREFIX/bin"
cp bwa-mem2 "$PREFIX/bin/"
cp bwa-mem2.sse41 "$PREFIX/bin/"
cp bwa-mem2.avx2 "$PREFIX/bin/"
cp bwa-mem2.avx512bw "$PREFIX/bin/"
