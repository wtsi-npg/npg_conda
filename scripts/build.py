#!/usr/bin/env python3

# Usage: ./scripts/package_sort.py [args] | ./scripts/build.py

import os
import sys
import subprocess
import time

def docker_pull(image):
    subprocess.check_output(['docker', 'pull', image])

RECIPES_DIR=os.path.expandvars("$HOME/conda-recipes")
ARTEFACTS_DIR=os.path.expandvars("$HOME/conda-artefacts")
CONDA_RECIPES_MOUNT="/home/conda/recipes"
CONDA_BUILD_MOUNT="/opt/conda/conda-bld"

IRODS_BUILD_IMAGE="wsinpg/conda-irods-12.04:0.2"
docker_pull(IRODS_BUILD_IMAGE)

CONDA_BUILD_IMAGE="wsinpg/conda-12.04:0.2"
docker_pull(CONDA_BUILD_IMAGE)

for line in sys.stdin.readlines():
    line.rstrip();
    name, version, path = line.split()
    print("%s %s %s" % (name, version, path))

    build_image = CONDA_BUILD_IMAGE
    if name == "irods":
        build_image = IRODS_BUILD_IMAGE
    print("Using image %s" % build_image)

    build_script = 'export CONDA_BLD_PATH="%s" ; ' \
        'cd "%s/npg_conda" && conda build %s' % \
        (CONDA_BUILD_MOUNT, CONDA_RECIPES_MOUNT, path)

    subprocess.check_output(
        ['docker', 'run',
         '--mount',
         'source=%s,target=%s,type=bind' % (RECIPES_DIR, CONDA_RECIPES_MOUNT),
         '--mount',
         'source=%s,target=%s,type=bind' % (ARTEFACTS_DIR, CONDA_BUILD_MOUNT),
         '-i', '-e', 'CONDA_USER_ID=1000',
         build_image,
         'sh', '-c', build_script])
