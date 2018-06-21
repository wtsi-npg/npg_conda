#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

mkdir -p "$SRC_DIR/bin"
make -j $n MACHTYPE=X86_64 BINDIR="$SRC_DIR/bin"

mkdir -p "$PREFIX/bin"

for f in blat faToNib faToTwoBit gfClient gfServer \
              nibFrag pslPretty pslReps pslSort twoBitInfo twoBitToFa; do
    cp "$SRC_DIR/bin/$f" "$PREFIX/bin/"
done
