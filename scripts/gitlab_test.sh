#! /bin/bash

set -e -u -x

IFS=$'\n'
for pkg in $(conda search --quiet -c file://$1 --override-channels | cut -f 1,2 -d ' ' | sed -E 's/[[:space:]]+/ /g') # $CHANNEL_DIR
do
    if [ "$pkg" == 'Loading channels:' ] || [ "$pkg" == '# Name' ]
    then
        continue
    fi
    
    unset IFS
    pkg=($pkg)
    conda create -y -n ${pkg[0]} -c file://$1 ${pkg[0]}=${pkg[1]}
    conda activate ${pkg[0]}
    conda env export
    echo "CHECKSUM = $(conda env export | md5sum)"
    if [[ -f $CONDA_DIR/pkgs/${pkg[0]}-${pkg[1]}*/info/test/run_test.* ]] # some packages do not have tests, e.g. irods-runtime
    then
        test=$(ls $CONDA_DIR/pkgs/${pkg{[0]}-${pkg[1]}*/info/test/run_test.*)
        case "$test" in
            [*.sh])
                bash "$test"
                ;;
            [*.py])
                python "$test"
                ;;
            [*.pl])
                perl "$test"
                ;;
        esac
    fi
    conda deactivate
    conda remove -y -n ${pkg{[0]} --all
done

unset IFS

