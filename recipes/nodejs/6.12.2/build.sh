#!/bin/sh

set -e

./configure --prefix="$PREFIX"

make -j 3
make install

PATH="$PREFIX/bin:$PATH" npm install -g npm@4.5.0
