#!/bin/bash

set -ex

untar_data() {
    if [ -e data.tar.gz ]; then
        tar xz --strip-components=0 --directory="$PREFIX" \
            --exclude='*.o' --exclude-backups < data.tar.gz
    elif [ -e data.tar.xz ]; then
        tar xJ --strip-components=0 --directory="$PREFIX" \
            --exclude='*.o' --exclude-backups < data.tar.xz
    fi
}

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

mkdir build_irods
pushd build_irods
cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CLANG=${BUILD_PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CPPZMQ=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_ARCHIVE=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_AVRO=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_BOOST=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_CLANG_RUNTIME=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_ZMQ=${PREFIX} \
    -D IRODS_EXTERNALS_FULLPATH_JANSSON=${PREFIX} \
    -D IRODS_LINUX_DISTRIBUTION_NAME='Ubuntu' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_MAJOR='12' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_CODENAME='Precise' \
    -D IRODS_EXTERNALS_FULLPATH_CATCH2=${PREFIX} \
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
popd

mkdir unpack
pushd unpack
${AR} vx ../build_irods/irods-dev_4.2.7~Precise_amd64.deb
untar_data

${AR} vx ../build_irods/irods-runtime_4.2.7~Precise_amd64.deb
untar_data
popd

mkdir build_icommands
pushd build_icommands
cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D IRODS_LINUX_DISTRIBUTION_NAME='Ubuntu' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_MAJOR='12' \
    -D IRODS_LINUX_DISTRIBUTION_VERSION_CODENAME='Precise' \
    -D IRODS_DIR="${PREFIX}/lib/irods/cmake" \
    -D CMAKE_CXX_FLAGS='-Wno-deprecated-declarations' \
    -D CMAKE_LD_FLAGS='-Wno-deprecated-declarations' \
    -D CMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib -fuse-ld=${LD}" \
    -D CMAKE_C_COMPILER="${BUILD_PREFIX}/bin/clang" \
    -D CMAKE_CXX_COMPILER="${BUILD_PREFIX}/bin/clang++" \
    -D CMAKE_AR=${AR} \
    -D CMAKE_LINKER=${LD} \
    -D TOOL_PREFIX="${HOST}-" \
    ../irods_client_icommands
make VERBOSE=1 -j "$CPU_COUNT" package
popd

pushd unpack
${AR} vx ../build_icommands/irods-icommands_4.2.7~Precise_amd64.deb
untar_data
popd

# Fix all the absolute symlinks pointing to /usr/include
perl -le 'use strict; use File::Basename; foreach (@ARGV) { if (my $f = readlink $_) { if ($f =~ m{^/usr/}sm) { unlink $_; symlink(basename($f), $_) } } }' $PREFIX/include/irods/*.hpp
