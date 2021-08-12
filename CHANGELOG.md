# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]


## [4.0.0]

### Added

#### Recipes
 - bambi 0.14.0
 - baton 3.0.0, 3.0.1
 - capnproto 0.7.0
 - gnutls 3.7.1, 3.7.2
 - hisat 2.1.0
 - iRODS
   - 4.2.10
   - 4.2.9
     - avrocpp 1.9.0
   - 4.2.8
     - avrocpp 1.8.2
     - json 3.9.1
     - krb5 1.19.1
     - libarchive 3.5.1
     - nanodbc 2.13.0
 - mash 2.3
 - samtools/htslib/bcftools 1.12, 1.13
 - seqtk 1.3
 - wr 0.23.3, 0.23.4, 0.25.0, 0.26.0

#### Features
 - Automatic package building on pull requests
 - Build variants for packages depending on iRODS libraries
 - --pull-build-image CLI option for build script
 - --output-packages CLI option for recipebook script

### Removed
 - fastx_toolkit 0.0.14
 - iRODS 4.1.12
 - Dependencies on conda-forge and consequently the "red recipes".

### Changed
 - Build host image changed from Ubuntu 12.04 to CentOS 7.
 - Update recipes to build with Conda >= 4.10.3 to use GCC 9.3 and glibc 2.17.
 - The URL for boost source code was updated.
 - The --sub-packages CLI option of the recipebook script now acts as a
   modifier for --output-packages to print only sub-packages.
 - krb requirement to krb-dev for irods 4.2.7
 - The default behaviour of the build script is no longer to pull the build
   image, but to expect to find it locally.

## [3.0.0]
