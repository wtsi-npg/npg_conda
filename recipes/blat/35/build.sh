#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

mkdir -p "$SRC_DIR/bin"
make -j $n MACHTYPE=X86_64 BINDIR="$SRC_DIR/bin"

mkdir -p "$PREFIX/bin"
cp "$SRC_DIR/bin/blat" "$PREFIX/bin/"
