#!/bin/sh

set -e

cd ./c
perl -i -ple 's/^(\t\$\(CC\).*?)$/$1 \$(LDFLAGS) \$(LDLIBS)/smx' Makefile
make ../bin/bam_stats CFLAGS="-I./ -I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

cp ../bin/bam_stats "$PREFIX/bin/"
