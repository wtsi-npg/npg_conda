#!/bin/sh

set -e

mkdir -p "$PREFIX/bin"
chmod a+x goleft_linux64
cp goleft_linux64 "$PREFIX/bin/goleft"
