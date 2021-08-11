#!/bin/sh

set -ex

mkdir -p "${PREFIX}/bin"

make CC="$GCC" CFLAGS="$CPPFLAGS $LDFLAGS"

make install BINDIR="${PREFIX}/bin"
