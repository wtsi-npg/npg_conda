#! /bin/bash

set -e -u -x

git fetch origin $1 # $COMPARE_BRANCH


rsync -rlv $2 $3 # $CHANNEL_DIR $BUILD_DIR

./bin/recipebook --changes origin/$1 recipes | ./bin/build \
 --recipes-dir $CI_PROJECT_DIR --artefacts-dir $3 --conda-build-image $CONDA_IMAGE \
 --build-channel $4 --conda-uid $(id -u gitlab-runner)  --conda-gid 32001 \
 --verbose --remove-container #$WSI_CONDA_CHANNEL

