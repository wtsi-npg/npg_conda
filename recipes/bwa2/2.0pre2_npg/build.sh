#!/bin/sh

set -ex

CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" make -j $CPU_COUNT CXX=icpc multi

mkdir -p "$PREFIX/bin"
cp bwa-mem2 "$PREFIX/bin/"
cp bwa-mem2.sse41 "$PREFIX/bin/"
cp bwa-mem2.avx2 "$PREFIX/bin/"
cp bwa-mem2.avx512bw "$PREFIX/bin/"
