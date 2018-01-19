#!/bin/sh

set -e

CC="$GCC -m64" ./configure --prefix="$PREFIX"
make install prefix="$PREFIX"
