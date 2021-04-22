#! /bin/bash

set -e -u -x

cleanup_env() {
    conda deactivate
    conda remove -n $1 --all # pkg[0]
}

check_package_in_channel() {
    
    if [[ "$1" =~  (^|[[:space:]])"$pkg"([[:space:]]|$) ]]   # channel_list (prod, devel or local)
    then
        IFS=' ' pkg=($pkg)
        (conda create -y -n ${pkg[0]} -c file://$CHANNEL_DIR ${changed[0]}==${changed[1]} &&# argument 1 from script arguments
             conda activate ${pkg[0]} &&
             conda install -c $2 ${pkg[0]}=${pkg[1]} &&#CONDA_CHANNEL
             conda env export &&
             echo "CHECKSUM = $(conda env export | md5sum)") || (echo "installation fail" && return 1)
        if [[ -f $CONDA_DIR/pkgs/${pkg[0]}-${pkg[1]}*/info/test/run_test.* ]] # some packages do not have tests, e.g. irods-runtime
        then
            test=$(ls $CONDA_DIR/pkgs/${pkg[0]}-${pkg[1]}*/info/test/run_test.*)
            case "$test" in
                [*.sh])
                    bash "$test" || (cleanup_env "${pkg[0]}" && echo "test fail" && return 2)
                    ;;
                [*.py])
                    python "$test" || (cleanup_env "${pkg[0]}" && echo "test fail" && return 2)
                    ;;
                [*.pl])
                    perl "$test" || (cleanup_env "${pkg[0]}" && echo "test fail" && return 2)
                    ;;
            esac
        fi
        cleanup_env "${pkg[0]}"
    else
        echo "not in channel"
        return 3
    fi
    return 0
}

CHANNEL_DIR=$1
IFS=$'\n'
prod=$(conda search --quiet -c $PROD_WSI_CONDA_CHANNEL --override-channels | sed -E 's/[[:space:]]+/ /g' | cut -f 1,2 -d' ')
devel=$(conda search --quiet -c $WSI_CONDA_CHANNEL --override-channels | sed -E 's/[[:space:]]+/ /g' | cut -f 1,2 -d' ')
local=$(conda search --quiet -c file://$CHANNEL_DIR --override-channels | sed -E 's/[[:space:]]+/ /g' | cut -f 1,2 -d ' ') 

for changed in $(tools/bin/recipebook --changes origin/$2) # COMPARE_BRANCH
do
    IFS=' ' changed=($changed)
    for pkg in $(tools/bin/recipebook --package ${changed[0]} --version ${changed[1]} --provides)
    do

        check_package_in_channel "$prod" "$PROD_WSI_CONDA_CHANNEL" ||
            check_package_in_channel "$devel" "$WSI_CONDA_CHANNEL" ||
            check_package_in_channel "$local" "file://$CHANNEL_DIR"
    done
done


