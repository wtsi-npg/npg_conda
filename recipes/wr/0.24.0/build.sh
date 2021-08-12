#!/bin/sh

set -e

mkdir -p "$PREFIX/bin"
cp wr "$PREFIX/bin/"

mkdir -p "$PREFIX/share/doc/wr"
cp README.md "$PREFIX/share/doc/wr/"
