#!/bin/bash

set -u

LOCAL=$1
REMOTE=/eos/experiment/ship/data/muflux/rawdata

in_list() {
    local search="$1"
    shift
    local list=("$@")
    for file in ${list[@]}; do
        [[ $file == $search ]] && return 0
    done
    return 1
}

count=0
for RUN in $LOCAL/*; do
    [[ $(basename "$RUN") =~ ^RUN_8000_2.{3}$ ]] || continue
    SPILLS=$RUN/*.raw*
    OUTPUTPATH="$REMOTE"/$(basename "$RUN")
    REMOTE_FILES=$(xrdfs "$EOSSHIP" ls "$OUTPUTPATH")
    for SPILL in $SPILLS; do
	if ! in_list "$OUTPUTPATH"/$(basename "$SPILL") "$REMOTE_FILES"; then
	    echo "$SPILL" >> files_to_upload.txt
	    (( count ++ ))
	fi
    done
done
echo $count
