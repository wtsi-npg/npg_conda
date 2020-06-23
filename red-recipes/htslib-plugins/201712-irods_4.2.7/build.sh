#!/bin/sh

set -ex

n="$CPU_COUNT"

pushd plugins
make IRODS_HOME="$PREFIX" \
     CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
popd
