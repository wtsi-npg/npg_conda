#!/bin/bash

set -ex

export TERM=dumb

pushd irods
git submodule init && git submodule update
popd

mkdir build_irods
pushd build_irods
cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -D IRODS_EXTERNALS_FULLPATH_CLANG=${BUILD_PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_ARCHIVE=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_AVRO=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_BOOST=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CATCH2=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CPPZMQ=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_JANSSON=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_ZMQ=${PREFIX} \
    -D IRODS_LINUX_DISTRIBUTION_NAME='Ubuntu' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_MAJOR='12' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_CODENAME='Precise' \
    -D CMAKE_C_FLAGS="-I${PREFIX}/include" \
    -D CMAKE_CXX_FLAGS='-Wno-deprecated-declarations' \
    -D CMAKE_LD_FLAGS='-Wno-deprecated-declarations' \
    -D CMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib -fuse-ld=${LD}" \
    -D CMAKE_C_COMPILER="${BUILD_PREFIX}/bin/clang" \
    -D CMAKE_CXX_COMPILER="${BUILD_PREFIX}/bin/clang++" \
    -D CMAKE_AR=${AR} \
    -D CMAKE_LINKER=${LD} \
    -D TOOL_PREFIX="${HOST}-" \
    ../irods
make VERBOSE=1 -j "$CPU_COUNT" package
make VERBOSE=1 install
popd

mkdir build_icommands
pushd build_icommands
cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -D IRODS_EXTERNALS_FULLPATH_CLANG=${BUILD_PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CLANG_RUNTIME=${PREFIX} \
    -D IRODS_LINUX_DISTRIBUTION_NAME='Ubuntu' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_MAJOR='12' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_CODENAME='Precise' \
    -D IRODS_DIR="${PREFIX}/lib/irods/cmake" \
    -D CMAKE_C_FLAGS="-I${PREFIX}/include" \
    -D CMAKE_CXX_FLAGS='-Wno-deprecated-declarations' \
    -D CMAKE_LD_FLAGS='-Wno-deprecated-declarations' \
    -D CMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib -fuse-ld=${LD}" \
    -D CMAKE_C_COMPILER="${BUILD_PREFIX}/bin/clang" \
    -D CMAKE_CXX_COMPILER="${BUILD_PREFIX}/bin/clang++" \
    -D CMAKE_AR=${AR} \
    -D CMAKE_LINKER=${LD} \
    -D CPP=${CPP} \
    ../irods_client_icommands
make VERBOSE=1 -j "$CPU_COUNT" package
make VERBOSE=1 install
popd
