# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Recipes

#### Features

### Removed

#### Recipes

### Changed

## [4.5.0]

### Added

#### Recipes
 - wr 0.32.0

#### Features

### Removed

#### Recipes

### Changed

#### Recipes 

## [4.4.0]

### Added

#### Recipes
 - baton 3.3.0

### Removed

#### Recipes
 - ml-warehouse 0.1.0

### Changed

## [4.3.1]

### Added

### Removed

### Changed
 - Gitlab CI: rsync location for prod channel build fixed

## [4.3.0]

### Added

#### Recipes
 - wr 0.30.0, 0.31.0, 0.31.1, 0.31.2
 - samtools/bcftools/htslib 1.15, 1.15.1
 - filebeat 8.1.2
 - ml-warehouse 0.1.0
 - iRODS 4.2.11

#### Features
 - Gitlab CI : master branch build will be pushed to prod channel

### Removed

#### Recipes
 - iRODS 4.2.8, 4.2.9

### Changed
 - build configs to use iRODS 4.2.11 and increment build numbers
   - baton 3.2.0
   - htslib-plugins 201712
   - tears 1.3.1

#### Recipes
 - remove spurious iRODS-dev dependency for io_lib
 - curl 7.58.0 to use Conda ca-certs
 - iRODS : pin the fmt dependency to a version <8.0

## [4.2.0]

### Added

#### Recipes
 - wr 0.28.0, 0.29.0
 - samtools/bctools/htslib 1.14
 - Build htslib-plugins for iRODS 4.2.10

#### Features

### Removed

#### Recipes
  - iRODS 4.2.8

### Changed
 - Python source file location moved to src
 - Use conda-build API


## [4.1.0]

### Added
 - wr 0.27.0

#### Recipes
 - baton 3.1.0, 3.2.0
 - Build variants for iRODS 4.2.7 and 4.2.10

#### Features
 - Add support for Conda build variants and Conda versions

### Removed

### Changed
 - Python source file location moved to src
 - Use conda-build API
 - find_changed_recipe_files returns relative paths
 - Add a requirement for Python >=3.9, due to the use of Path.is_relative_to
 - Add `.` to requirments.txt so that pip will install the local tools and their modules when `pip install -r requirments` is run.
 - Move Python source files to ./src and unify python files into a module structure
 - Allow tests to be run from any directory.


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
