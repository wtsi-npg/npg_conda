#!/bin/sh

set -ex

n="$CPU_COUNT"

# N.B. CPPFLAGS must reset all the values used by htslib subdirectory,
# otherwise they will be lost. Don't set LDFLAGS because the STAR
# Makefile is broken and the values of other flags will be lost.

pushd source
make -j $n STAR STARlong \
    CPPFLAGS="-I$SRC_DIR/source/htslib -I$PREFIX/include -DSAMTOOLS=1" \
    LDFLAGSextra="-L$SRC_DIR/source/htslib -L$PREFIX/lib"

mkdir -p "$PREFIX/bin"
cp STAR "$PREFIX/bin"
cp STARlong "$PREFIX/bin"
popd
