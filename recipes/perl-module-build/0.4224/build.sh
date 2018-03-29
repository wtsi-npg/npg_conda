#!/bin/sh

set -e

perl Makefile.PL INSTALL_BASE="$PREFIX"
make
make install 
