#!/bin/bash

set -x
set -u

DIR=$1
EOSSHIP=root://eospublic.cern.ch/
inotifywait -r -m "$DIR" -e create -e moved_to |
    while read -r path action FILE; do
        echo "The file '$FILE' appeared in directory '$path' via '$action'"
	[[ $(basename "$FILE") =~ ^run ]] && RUNDIR=$(basename "$FILE") && RUN=${RUNDIR:3} && RUN=$((10#$RUN)) && ./elog.py --text "New run $RUN being backed up." --subject "Start backup run $RUN" --run $RUN && continue
	RUNDIR=$(basename "$path")
	RUN=${RUNDIR:3}
	RUN=$((10#$RUN))
	RUNDIR=RUN_0B00_$(printf "%04d" $RUN)
	OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
	xrdfs "$EOSSHIP" stat "$OUTPUTPATH" || xrdfs "$EOSSHIP" mkdir "$OUTPUTPATH"
	xrdfs "$EOSSHIP" stat "$OUTPUTPATH"/"$(basename "$FILE")" && echo "File $FILE already uploaded" && continue
	xrdcp "$path""$FILE" "$EOSSHIP""$OUTPUTPATH"
    done
