#! /bin/bash

set -e -u -x

git fetch origin $1 # $COMPARE_BRANCH


rsync -av $2 $3 # $CHANNEL_DIR $BUILD_DIR

./tools/bin/recipebook --changes origin/$1 recipes | ./tools/bin/build \
 --recipes-dir $CI_PROJECT_DIR --artefacts-dir $3 --conda-build-image $CONDA_IMAGE \
 --build-channel $WSI_CONDA_CHANNEL \
 --verbose --remove-container

./tools/bin/recipebook --changes origin/$1 red-recipes | ./tools/bin/build \
 --recipes-dir $CI_PROJECT_DIR --artefacts-dir $3 --conda-build-image $CONDA_IMAGE \
 --build-channel $WSI_CONDA_CHANNEL conda-forge bioconda \
 --verbose --remove-container
