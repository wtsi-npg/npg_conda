#!/bin/sh

set -ex

cd ./c
make ../bin/bam_stats CC="$GCC" \
     CFLAGS="-O3 -DVERSION='\"$PKG_VERSION\"' -g" \
     CPPFLAGS="-I$PREFIX/include" \
     LDFLAGS="-L$PREFIX/lib"

cp ../bin/bam_stats "$PREFIX/bin/"
