#!/bin/bash

set -x
set -u

RUNDIR=$1
DIR=/data/SHiP_testBeam/Data/"$RUNDIR"

for FILE in $DIR/*; do
	[[ ! $FILE == *.raw ]] && continue
	[[ $(basename "$FILE") =~ ^RUN_8000_.{4}$ ]] && RUNDIR=$(basename "$FILE") && RUN=${RUNDIR:9} && RUN=$((10#$RUN)) && continue
	RUNDIR=$(basename "$(dirname "$FILE")")
	RUN=${RUNDIR:9}
	RUN=$((10#$RUN))
	OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
	xrdfs "$EOSSHIP" stat "$OUTPUTPATH" || xrdfs "$EOSSHIP" mkdir "$OUTPUTPATH"
	xrdfs "$EOSSHIP" stat "$OUTPUTPATH"/"$(basename "$FILE")" && echo "File $FILE already uploaded" && continue
	xrdcp "$FILE" "$EOSSHIP""$OUTPUTPATH" && flock files_to_convert.lock echo "$EOSSHIP$OUTPUTPATH$(basename "$FILE")" >> files_to_convert.txt
    done
