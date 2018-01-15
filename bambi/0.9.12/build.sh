#!/bin/sh

set -e

autoreconf -fi

./configure --prefix="$PREFIX" --with-htslib="$PREFIX"

make install prefix="$PREFIX"
