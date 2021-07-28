#! /bin/bash

set -e -u -x

mkdir -p $1 # $CHANNEL_DIR
mkdir -p $2 # $BUILD_DIR

if [ ! -d $CONDA_DIR ]
then
    
    wget --quiet $MINICONDA -O /tmp/miniconda.sh
    /bin/bash /tmp/miniconda.sh -b -p $CONDA_DIR
    $CONDA_DIR/bin/conda clean -tipsy

    echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc
    echo "conda activate base" >> ~/.bashrc

    . $CONDA_DIR/etc/profile.d/conda.sh
    conda activate base
    conda config --set auto_update_conda False
    conda config --prepend channels "$WSI_CONDA_CHANNEL"
    conda config --append channels conda-forge

else
    . $CONDA_DIR/etc/profile.d/conda.sh
    conda activate base    
fi

conda install conda-build

pip install -r ./requirements.txt
pip install awscli-plugin-endpoint

aws configure set plugins.endpoint awscli_plugin_endpoint
aws configure set s3.endpoint_url $S3_URL
aws configure set s3api.endpoint_url $S3_URL

aws s3 sync "$3" "$1" # $CHANNEL_REM $CHANNEL_DIR

