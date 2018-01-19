#!/bin/sh

set -e

tar xvfz bcl2fastq2-v2.20.0.422-Source.tar.gz
mkdir bcl2fastq/build
cd bcl2fastq/build

export CPPFLAGS="-I$PREFIX/include"
export CFLAGS="-B/usr/lib/x86_64-linux-gnu"
export LDFLAGS="-L$PREFIX/lib"

n=`expr $CPU_COUNT / 4 \| 1`
../src/configure --prefix="$PREFIX" --parallel=$n
make -j $n install prefix="$PREFIX"
