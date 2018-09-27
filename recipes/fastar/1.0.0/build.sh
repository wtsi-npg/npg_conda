#!/bin/sh

set -e

mkdir -p "$PREFIX/bin"
chmod a+x fastar
cp fastar "$PREFIX/bin/"
