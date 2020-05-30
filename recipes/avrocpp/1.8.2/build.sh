#!/bin/bash
set -exuo pipefail

mkdir build
cd build
echo prefix=${PREFIX}
export CXXFLAGS="-I$BUILD_PREFIX/include"
export LDFLAGS="-L$BUILD_PREFIX/lib -lrt"
echo $CXXFLAGS

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DBOOST_ROOT=$PREFIX \
  -DSNAPPY_ROOT_DIR=$PREFIX \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_AR=$AR 

make # VERBOSE=1
#make test
make install
