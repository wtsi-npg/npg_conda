#!/bin/bash

set -ex

running_in_docker() {
    if [ -f /.dockerenv ]; then
        return 0
    else
        return 1
    fi
}

export TERM=dumb

if running_in_docker ; then
    echo "Running in Docker ... "
fi

pushd irods
git submodule init && git submodule update
popd

[ -d build_irods ] || mkdir build_irods
pushd build_irods
cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -D IRODS_EXTERNALS_FULLPATH_CLANG=${BUILD_PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CLANG_RUNTIME=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_ARCHIVE=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_AVRO=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_BOOST=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CATCH2=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CPPZMQ=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_FMT=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_JANSSON=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_JSON=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_NANODBC=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_ZMQ=${PREFIX} \
    -D IRODS_LINUX_DISTRIBUTION_NAME='ubuntu' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_MAJOR='18' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_CODENAME='bionic' \
    -D CMAKE_C_FLAGS="-I${PREFIX}/include" \
    -D CMAKE_CXX_FLAGS='-Wno-deprecated-declarations' \
    -D CMAKE_LD_FLAGS='-Wno-deprecated-declarations' \
    -D CMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib -fuse-ld=${LD}" \
    -D CMAKE_SHARED_LINKER_FLAGS="-Wl,-allow-multiple-definition" \
    -D CMAKE_C_COMPILER="${BUILD_PREFIX}/bin/clang" \
    -D CMAKE_CXX_COMPILER="${BUILD_PREFIX}/bin/clang++" \
    -D BUILD_UNIT_TESTS=OFF \
    -D CMAKE_AR=${AR} \
    -D CMAKE_LINKER=${LD} \
    -D CPP=${CPP} \
    ../irods
make VERBOSE=1 -j "$CPU_COUNT" package
make VERBOSE=1 install
popd

[ -d build_icommands ] || mkdir build_icommands
pushd build_icommands
cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -D IRODS_EXTERNALS_FULLPATH_CLANG=${BUILD_PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CLANG_RUNTIME=${PREFIX} \
    -D IRODS_LINUX_DISTRIBUTION_NAME='ubuntu' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_MAJOR='18' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_CODENAME='bionic' \
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
make install
popd
