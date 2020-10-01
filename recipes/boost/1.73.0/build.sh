#!/bin/sh

set -ex

n="$CPU_COUNT"

# bootstrap fails because it has the 'gcc' executable name hard-coded
# and doesn't respect Conda's "$GCC" environment variable:

shopt -u | grep -q nullglob && nullglob_enabled=0
[ $nullglob_enabled ] || shopt -s nullglob

for f in ar as c++ cc cpp g++ gcc gcc-ar gcc-nm gcc-ranlib ld; do
    fullname=($BUILD_PREFIX/bin/*-$f)
    shortname="$BUILD_PREFIX/bin/$f"
    [ -h "$shortname" ] || ln -s "$fullname" "$shortname"
done

[ $nullglob_enabled ] || shopt -u nullglob

./bootstrap.sh --prefix="$PREFIX" --with-toolset=gcc --without-libraries=python

# The cxxflags and linkflags options are not well documented. They do
# not appear in `./b2 --help` and are only mentioned in the HTML docs
# for the "sun" toolset.
./b2 -j $n --prefix="$PREFIX" --layout=system \
     cxxstd=14 \
     cxxflags="-I$PREFIX/include" \
     linkflags="-L$PREFIX/lib" \
     link=shared runtime-link=shared \
     threading=multi variant=release \
     install
