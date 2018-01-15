#!/bin/sh

set -e

./configure --prefix="$PREFIX"
make install prefix="$PREFIX"
