#! /bin/bash

set -e -u -x

git fetch origin $COMPARE_BRANCH

rsync -av $CHANNEL_DIR/ $BUILD_DIR

./tools/bin/recipebook --changes origin/$COMPARE_BRANCH recipes | ./tools/bin/build \
 --recipes-dir $CI_PROJECT_DIR --artefacts-dir $BUILD_DIR --conda-build-image $CONDA_IMAGE \
 --verbose --remove-container

./tools/bin/recipebook --changes origin/$COMPARE_BRANCH red-recipes | ./tools/bin/build \
 --recipes-dir $CI_PROJECT_DIR --artefacts-dir $BUILD_DIR --conda-build-image $CONDA_IMAGE \
 --verbose --remove-container
