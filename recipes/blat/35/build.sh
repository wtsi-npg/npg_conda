#!/bin/sh

set -ex

n="$CPU_COUNT"

mkdir -p "$SRC_DIR/bin"

export XINC="-I$PREFIX/include"
make -j $n MACHTYPE=X86_64 BINDIR="$SRC_DIR/bin" \
     CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

mkdir -p "$PREFIX/bin"

for f in blat faToNib faToTwoBit gfClient gfServer \
              nibFrag pslPretty pslReps pslSort twoBitInfo twoBitToFa; do
    cp "$SRC_DIR/bin/$f" "$PREFIX/bin/"
done
