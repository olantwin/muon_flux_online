#!/bin/bash

in_list() {
    local search="$1"
    shift
    local list=("$@")
    for file in ${list[@]}; do
        [[ $file == $search ]] && return 0
    done
    return 1
}

set -u

DIR=$1
EOSSHIP=root://eospublic.cern.ch/

RUNDIR=$(basename "$DIR")
RUN=${RUNDIR:3}
RUN=$((10#$RUN))
RUNDIR=RUN_0B00_$(printf "%04d" $RUN)
OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
xrdfs "$EOSSHIP" stat "$OUTPUTPATH" || xrdfs "$EOSSHIP" mkdir "$OUTPUTPATH"
EOSFILES=$(xrdfs "$EOSSHIP" ls "$OUTPUTPATH")
for FILE in $DIR/*.dat; do
    if ! in_list "$OUTPUTPATH"/"$(basename "$FILE")" "$EOSFILES"; then
	xrdcp "$FILE" "$EOSSHIP""$OUTPUTPATH"
    else
	echo "File $FILE already uploaded"
    fi
done
