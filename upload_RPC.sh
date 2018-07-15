#!/bin/bash

set -x
set -u

DIR=$1

for FILE in $DIR/*.dat; do
	RUNDIR=$(basename "$(dirname "$FILE")")
	RUN=${RUNDIR:3}
	RUN=$((10#$RUN))
	RUNDIR=RUN_0B00_$(printf "%04d" $RUN)
	OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
	xrdfs "$EOSSHIP" stat "$OUTPUTPATH" || xrdfs "$EOSSHIP" mkdir "$OUTPUTPATH"
	xrdfs "$EOSSHIP" stat "$OUTPUTPATH"/"$(basename "$FILE")" && echo "File $FILE already uploaded" && continue
	xrdcp "$FILE" "$EOSSHIP""$OUTPUTPATH"
    done
