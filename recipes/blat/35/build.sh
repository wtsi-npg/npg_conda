#!/bin/sh

set -ex

n="$CPU_COUNT"

# building fails because it has the 'ar' executable name hard-coded
# and doesn't respect Conda's "$AR" environment variable:

shopt -u | grep -q nullglob && nullglob_enabled=0
[ $nullglob_enabled ] || shopt -s nullglob

for f in ar gcc-ar; do
    fullname=($BUILD_PREFIX/bin/*-$f)
    shortname="$BUILD_PREFIX/bin/$f"
    [ -h "$shortname" ] || ln -s "$fullname" "$shortname"
done

[ $nullglob_enabled ] || shopt -u nullglob

mkdir -p "$SRC_DIR/bin"

export XINC="-I$PREFIX/include"
make -j $n MACHTYPE=X86_64 BINDIR="$SRC_DIR/bin" \
     CC="$GCC" \
     CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

mkdir -p "$PREFIX/bin"

for f in blat faToNib faToTwoBit gfClient gfServer \
              nibFrag pslPretty pslReps pslSort twoBitInfo twoBitToFa; do
    cp "$SRC_DIR/bin/$f" "$PREFIX/bin/"
done
