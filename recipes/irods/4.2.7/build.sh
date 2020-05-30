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

unrpm_data() {
    local rpm="$1"
    mkdir -p ./tmp
    pushd tmp
    rpm2cpio ../"$rpm" | cpio --extract --make-directories
    popd
    tar cf - -C ./tmp . | tar xv --strip-components=2 --directory="$PREFIX" \
                              --exclude='*.o' --exclude-backups
    rm -r ./tmp
}

running_in_docker() {
    if [ -f /.dockerenv ]; then
        return 0
    else
        return 1
    fi
}

install_gcc_ubuntu() {
    GCC_VERSION=
    grep precise /etc/lsb-release && GCC_VERSION="4.6"
    grep xenial  /etc/lsb-release && GCC_VERSION="4.8"
    grep bionic  /etc/lsb-release && GCC_VERSION="4.8"

    sudo apt-get install -y "g++-$GCC_VERSION" "gcc-$GCC_VERSION"

    sudo update-alternatives --install /usr/bin/gcc gcc "/usr/bin/gcc-$GCC_VERSION" 100
    sudo update-alternatives --install /usr/bin/g++ g++ "/usr/bin/g++-$GCC_VERSION" 100
    sudo update-alternatives --set gcc "/usr/bin/gcc-$GCC_VERSION"
    sudo update-alternatives --set g++ "/usr/bin/g++-$GCC_VERSION"
}

install_deps_ubuntu() {
    sudo apt-get install -y autoconf automake help2man make \
         libtool pkg-config texinfo

    sudo apt-get install -y libjson-perl python-dev

    sudo apt-get install -y libbz2-dev libcurl4-gnutls-dev \
         libfuse-dev libkrb5-dev libmysqlclient-dev libpam0g-dev \
         libssl-dev unixodbc-dev libxml2-dev zlib1g-dev
}

# Requires:
#
# sudo subscription-manager register --org="..." --activationkey="..."
# sudo subscription-manager repos --enable rhel-7-server-extras-rpms
# sudo subscription-manager repos --enable rhel-7-server-supplementary-rpms
# sudo subscription-manager repos --enable rhel-7-server-optional-rpms

install_gcc_rhel() {
    sudo yum install -y gcc-c++
}

install_deps_rhel() {
    sudo yum install -y help2man make rpm-build

    sudo yum install -y perl-JSON python-devel

    sudo yum install -y bzip2-devel curl-devel \
         fuse-devel krb5-devel pam-devel \
         openssl-devel unixODBC-devel libxml2-devel zlib-devel
}

export TERM=dumb

if [ -f /etc/lsb-release ]; then
    if running_in_docker ; then
        echo "Running in Docker ... skipping package installation"
#    else
        #install_gcc_ubuntu
        #install_deps_ubuntu
    fi

    export CFLAGs="-I$PREFIX/include"
    export CCFLAGS="-I$PREFIX/include -Wno-deprecated-declarations"
    export CXXFLAGS="-I$PREFIX/include -Wno-deprecated-declarations"
    export LDFLAGS="-L$PREFIX/lib"
    mkdir build_irods
    mkdir build_icommands
    cd build_irods

    git submodule init && git submodule update
    cmake -D CMAKE_INSTALL_PREFIX=${PREFIX} -D IRODS_EXTERNALS_FULLPATH_CLANG=${BUILD_PREFIX} -D IRODS_EXTERNALS_FULLPATH_CPPZMQ=${PREFIX} -D IRODS_EXTERNALS_FULLPATH_ARCHIVE=${PREFIX} -D IRODS_EXTERNALS_FULLPATH_AVRO=${PREFIX} -D IRODS_EXTERNALS_FULLPATH_BOOST=${PREFIX} -D IRODS_EXTERNALS_FULLPATH_CLANG_RUNTIME=${PREFIX} -D IRODS_EXTERNALS_FULLPATH_ZMQ=${PREFIX} -D IRODS_EXTERNALS_FULLPATH_JANSSON=${PREFIX} -D CMAKE_C_FLAGS="-I$PREFIX/include" -D CMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib -fuse-ld=$LD" \
	   -D IRODS_LINUX_DISTRIBUTION_NAME='Ubuntu' -D IRODS_LINUX_DISTRIBUTION_VERSION_MAJOR='12' -D IRODS_LINUX_DISTRIBUTION_VERSION_CODENAME='Precise' -D IRODS_EXTERNALS_FULLPATH_CATCH2=${PREFIX} -DCMAKE_AR=$AR -DCMAKE_LINKER=$LD -DCMAKE_SYSROOT=${PREFIX}  ../irods
    make -j${CPU_COUNT} package
    #for the icommands
    cd ..
    mkdir build
    cd build
    ${AR} vx ../build_irods/irods-dev_4.2.7~Precise_amd64.deb
    untar_data
    ${AR} vx ../build_irods/irods-runtime_4.2.7~Precise_amd64.deb
    untar_data
    cd ../build_icommands
    cmake -D CMAKE_CXX_FLAGS='-Wno-deprecated-declarations -Wno-unused-command-line-argument' -D CMAKE_INSTALL_PREFIX=${PREFIX} -D IRODS_DIR=$PREFIX/lib/irods/cmake -D CMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib" -D IRODS_LINUX_DISTRIBUTION_NAME='Ubuntu' -D IRODS_LINUX_DISTRIBUTION_VERSION_MAJOR='12' -D IRODS_LINUX_DISTRIBUTION_VERSION_CODENAME='Precise' -DCMAKE_AR=$AR -DCMAKE_LINKER=$LD -D CMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib -fuse-ld=$LD" -DCMAKE_SYSROOT=${PREFIX} ../irods_client_icommands
    make -j${CPU_COUNT} package
    cd ../build
    ${AR} vx ../build_icommands/irods-icommands_4.2.7~Precise_amd64.deb
    untar_data

fi

if [ -f /etc/redhat-release ]; then
    if running_in_docker ; then
        echo "Running in Docker ... skipping package installation"
    else
        install_gcc_rhel
        install_deps_rhel
    fi

    export CCFLAGS="$PREFIX/include"
    export LDRFLAGS="$PREFIX/lib"
    ./packaging/build.sh --verbose icat postgres
    ./packaging/build.sh --verbose icommands

    cd build

    unrpm_data irods-icommands-4.1.12-64bit-centos[0-9].rpm
    unrpm_data irods-dev-4.1.12-64bit-centos[0-9].rpm
fi

# Fix all the absolute symlinks pointing to /usr/include
perl -le 'use strict; use File::Basename; foreach (@ARGV) { if (my $f = readlink $_) { if ($f =~ m{^/usr/}sm) { unlink $_; symlink(basename($f), $_) } } }' $PREFIX/include/irods/*.hpp
