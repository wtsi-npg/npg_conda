#!/bin/sh

set -e

./configure --prefix="$PREFIX" --with-libmaus2="$PREFIX"
make install prefix="$PREFIX"
