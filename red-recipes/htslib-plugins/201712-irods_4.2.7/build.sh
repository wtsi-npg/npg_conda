#!/bin/sh

set -ex

n="$CPU_COUNT"

pushd plugins
make IRODS_HOME="$PREFIX" \
     CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" \
     PLUGINS="hfile_irods_wrapper.so hfile_irods.so hfile_mmap.so"
make install prefix="$PREFIX" \
     PLUGINS="hfile_irods_wrapper.so hfile_irods.so hfile_mmap.so"
popd
