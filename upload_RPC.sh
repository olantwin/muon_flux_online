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
RUN=$((10#${RUNDIR:3}))
RUNDIR=RUN_0B00_$(printf "%04d" $RUN)
OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
xrdfs "$EOSSHIP" stat "$OUTPUTPATH" || xrdfs "$EOSSHIP" mkdir "$OUTPUTPATH"
EOSFILES=$(xrdfs "$EOSSHIP" ls "$OUTPUTPATH")
for FILE in $DIR/*16_1.dat; do
    SPILL=$(tmp=$(basename "$FILE"); echo "${tmp:13:8}")
    OUTPUTFILE=SPILLDATA_"$SPILL".tar
    FILES=($(tmp=$(basename "$FILE"); echo "${tmp%_??_?.dat}")*.dat)
    if ! in_list "$OUTPUTPATH"/"$OUTPUTFILE" "$EOSFILES"; then
	tar -cf "$OUTPUTFILE" "${FILES[@]}"
	xrdcp "$OUTPUTFILE" "$EOSSHIP""$OUTPUTPATH" && rm "$OUTPUTFILE"
    else
	echo "File $FILE already uploaded"
    fi
done
