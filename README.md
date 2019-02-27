This repository contains [Conda](https://conda.io) recipes to build
tools and libraries used by [WSI NPG](https://github.com/wtsi-npg).

Our recipes differ from those provided by
[Anaconda Inc.](https://github.com/AnacondaRecipes),
[Conda Forge](https://conda-forge.org) and
[BioConda](https://bioconda.github.io/) in order to meet our specific
needs:

* Build artefacts are separated into sub-packages. For a typical
  package written in C and named `example`, these would be:

  * `example-bin` containing executables and their documentation, such
    as manpages.

  * `libexample` containing the example libraries (static and shared).

  * `example-dev` containing the C headers, any pkg-config files,
    build-time configuration executables and API manpages.

* Recipes depend only on the Anaconda `defaults` channel

* We maintain recipes for multiple versions of packages in
  production. The recipes are located in directory hierarchy by name
  and version.

* Recipes do not support Windows or MacOS.

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

We don't use the Windows or MacOS platforms, so we simplify our
recipes by omitting support for them.

### Building the recipes ###

Building from source requires Conda (we use
[Miniconda](https://docs.conda.io/en/latest/miniconda.html)), with the
[conda-build](https://github.com/conda/conda-build) and
[conda-verify](https://github.com/conda/conda-verify) packages
installed.

A complete from-source build can be achieved using the
`./scripts/package_sort.py` script which inspects the recipes,
calculates their dependency DAG and then outputs a list sorted so that
they are built in the correct order:

    ./scripts/package_sort.py recipes/ | head -4
    rna-seqc 1.1.8 recipes/rna-seqc/1.1.8
    bowtie2 2.2.7 recipes/bowtie2/2.2.7
    teepot 1.2.0 recipes/teepot/1.2.0
    eigen 3.3.4 recipes/eigen/3.3.4

The list of recipe paths may be passed directly to `conda-build`:

    ./scripts/package_sort.py recipes | awk '{print $3}' | xargs conda-build 

which will build everything using just the Anaconda defaults channel
and the local channel for dependencies.
