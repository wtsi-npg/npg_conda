This repository contains [Conda](https://conda.io) recipes to build
tools and libraries used by [WSI NPG](https://github.com/wtsi-npg).

Our recipes differ from those provided by
[Anaconda Inc.](https://github.com/AnacondaRecipes),
[Conda Forge](https://conda-forge.org) and
[BioConda](https://bioconda.github.io/) in order to meet our specific
needs:

* Build artefacts are separated into sub-packages. For a typical
  package written in C and named `example`, these would be:

  * `example` containing executables and their documentation, such
    as manpages.

  * `libexample` containing the example libraries (static and shared).

  * `example-dev` containing the C headers, any pkg-config files,
    build-time configuration executables and API manpages.

* Recipes depend only on the Anaconda `defaults` channel

* We maintain recipes for multiple versions of packages in
  production. The recipes are located in directory hierarchy by name
  and version.

* Recipes do not support Windows or macOS.

Typical Conda recipes create a single package bundling all build
artefacts (executables, libraries, headers, manpages etc) together, so
installing a program that depends on a C shared library from another
package will cause any executables in that package also to be
installed in the target environment. This is something we specifically
want to avoid.

We avoid using the `conda-forge` and `bioconda` channels so that we
are in complete control of the deployed package dependency graph and
do not unexpectedly upgrade (or downgrade) packages that may affect
data analysis.

We don't use the Windows or macOS platforms, so we simplify our
recipes by omitting support for them.

### Building the recipes ###

Building from source requires Conda (we use
[Miniconda](https://docs.conda.io/en/latest/miniconda.html)), with the
[conda-build](https://github.com/conda/conda-build) and
[conda-verify](https://github.com/conda/conda-verify) packages
installed.

Builds normally take place within the environment of a Docker
container. The benefits are

* Builds will take place in the same environment, regardless of which
  OS they are run under.

* Builds are isolated from one another because they each run in an
  independent container.

* Our default build image does not contain build tools or a compiler,
  which reduces the chance of these being used over the Conda build
  tools.

Our build image contains Conda pre-installed and works by mounting two
local directories, one which should contain the Conda recipes to build
and another which will receive the built packages. The
`bin/build` script handles mounting the directories and running
the builds. The build script requires a list of packages to be
supplied on STDIN and it will build them in that order.

This means that for a complete from-source build of all packages, they
must be sorted so that packages that have dependencies are built after
those they depend on. This can be achieved using the
`bin/recipebook` script which inspects the recipes,
calculates their dependency DAG and then outputs a list sorted so that
they are built in the correct order:

    ./bin/recipebook recipes/ | head -4
    rna-seqc 1.1.8 recipes/rna-seqc/1.1.8
    bowtie2 2.2.7 recipes/bowtie2/2.2.7
    teepot 1.2.0 recipes/teepot/1.2.0
    eigen 3.3.4 recipes/eigen/3.3.4

Both of these scripts have command line help and a number of options
to configure their behaviour. Note that the online help for `/bin/build`
reports default values dynamically (i.e. they are calculated for your
current environment so that they describe accurately the values that
will be used).

A complete build example:

    ./bin/recipebook | ./bin/build \
    --recipes-dir $PWD --artefacts-dir $HOME/conda-artefacts \
    --conda-build-image wsinpg/centos-7-conda:latest --verbose

Here the recipes directory that will be mounted by the container is
set explicitly, as is the artefacts directory, where the built
packages will appear (these are both mounted into the container).

The artefacts directory can be used by multiple builds,
sequentially. It will accumulate built packages that will be used as
dependencies by later builds. Alternatively, you may prefer to push
the built packages to a Conda channel and have later builds find them
there.

If there are errors Conda will report the full path to the failed
build so that you can investigate. Common reasons for build failures
(aside from errors in the new recipe) are

* The software being packaged requires an older or newer version of a
  compiler, build tool or library than is available in the channels

* The software being packaged has a build system that fails to
  respect `$PREFIX` during installation

* The software being packaged has undocumented dependencies

A successfully built package will be dropped in the output root
directory, the default being `<CONDA_PREFIX>/conda-bld/`. This may be
changed in the `.condarc` file or by setting the `CONDA_BLD_PATH`
environment variable, see
[Conda build configuration](https://conda.io/docs/user-guide/configuration/use-condarc.html#specify-conda-build-output-root-directory-root-dir)
section of the
[Conda User guide](https://conda.io/docs/user-guide/index.html)


### Naming new recipes ###

The rules are:

1. The package containing the executables should be named after the
commonly used name for the software (e.g. bwa, minimap2, curl)

2. If 1. is not possible, e.g. because the executables are in
sub-package, the Conda meta-package is renamed {package name}-pkg and
the executables sub-package keeps the common name
(e.g. curl-pkg,curl,libcurl,libcurl-dev).

3. If 2. is not possible because, e.g. the common name for the software
is a library name and the software also provides executables, then the
executables package is renamed {package}-bin,
(e.g. libml2-pkg,libxml2-bin,libxml2,libxml2-dev).


### Notes on glibc ###

The `defaults` Conda channel uses glibc 2.17 from CentOS 7.x. Our packages 
are built in a Docker CentOS 7.x container.

### Special compilers ###

iRODS requires Clang to build. The Clang package available from 
`conda-forge` is unable to locate the Conda GCC 9.3 installation. We have 
made forks of the [LLVM](https://github.com/wtsi-npg/llvmdev-feedstock) and 
[Clang](https://github.com/wtsi-npg/clangdev-feedstock) Conda recipes to 
work around this.

The packages may be built within the CentOS container using the following 
commands:

    docker run --mount \
    source=/home/ubuntu/llvmdev-feedstock,\
    target=/home/conda/recipes,type=bind \
    --mount \
    source=/home/ubuntu/conda-artefacts,\
    target=/opt/conda/conda-bld,type=bind \
    -e CONDA_USER_ID=1001 -e CONDA_GROUP_ID=1001 -i --rm \
    wsinpg/centos-7-conda:latest \ 
    /bin/sh -c 'exportCONDA_BLD_PATH="/opt/conda/conda-bld" ; conda config --set auto_update_conda False ; cd /home/conda/recipes && conda build recipe'

    docker run --mount \
    source=/home/ubuntu/clangdev-feedstock,\
    target=/home/conda/recipes,type=bind \
    --mount \
    source=/home/ubuntu/conda-artefacts,\
    target=/opt/conda/conda-bld,type=bind \
    -e CONDA_USER_ID=1001 -e CONDA_GROUP_ID=1001 -i --rm \
    wsinpg/centos-7-conda:latest \
    /bin/sh -c 'export CONDA_BLD_PATH="/opt/conda/conda-bld" ; conda config --set auto_update_conda False ; cd /home/conda/recipes && conda build recipe'
