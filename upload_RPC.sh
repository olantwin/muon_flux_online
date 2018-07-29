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

set -ux

DIR=$1
EOSSHIP=root://eospublic.cern.ch/

cd $DIR || exit 1

RUNDIR=$(basename "$DIR")
RUN=$((10#${RUNDIR:3}))
RUNDIR=RUN_0B00_$(printf "%04d" $RUN)
OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
xrdfs "$EOSSHIP" stat "$OUTPUTPATH" || xrdfs "$EOSSHIP" mkdir "$OUTPUTPATH"
EOSFILES=$(xrdfs "$EOSSHIP" ls "$OUTPUTPATH")
for FILE in *16_1.dat; do
    SPILL=$(tmp=$(basename "$FILE"); echo "${tmp:13:8}")
    OUTPUTFILE=/rsync_disk/home/nessie01/muon_flux_online/SPILLDATA_"$SPILL".tar
    FILES=(${FILE%_??_?.dat}*.dat)
    if ! in_list "$OUTPUTPATH"/"$OUTPUTFILE" "$EOSFILES"; then
	tar -cf "$OUTPUTFILE" "${FILES[@]}"
	xrdcp "$OUTPUTFILE" "$EOSSHIP""$OUTPUTPATH" && rm "$OUTPUTFILE"
    else
	echo "File $FILE already uploaded"
    fi
done
