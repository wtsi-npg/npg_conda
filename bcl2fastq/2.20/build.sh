#!/bin/sh

set -e

tar xvfz bcl2fastq2-v2.20.0.422-Source.tar.gz
mkdir bcl2fastq/build
cd bcl2fastq/build

# Workaround for sys/stat.h being moved from its usual place in Ubuntu
# Xenial
export "C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu"

export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

n=`expr $CPU_COUNT / 4 \| 1`

../src/configure --prefix="$PREFIX" --parallel=$n

make -j $n
make install prefix="$PREFIX"
