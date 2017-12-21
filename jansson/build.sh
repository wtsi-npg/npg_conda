#!/bin/sh

set -e

autoreconf -fi
./configure --prefix=$PREFIX
make install prefix=$PREFIX
