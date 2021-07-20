#! /usr/bin/env bash

mkdir "$1/channel"
export conda_test_variable=true
conda build --output-folder "$1/channel" "$1/recipes"
export conda_test_variable=''
