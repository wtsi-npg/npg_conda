#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

#pushd "$PREFIX/bin"
#ln -s $(basename "$AR")  ar
#ln -s $(basename "$GCC") cc
#ln -s $(basename "$LD")  ld
#popd

perl Makefile.PL INSTALL_BASE="$PREFIX" MP_APXS="$PREFIX/bin/apxs"

make -j $n # Target must be run separately from 'make install'
make install DESTDIR="$PREFIX/"
