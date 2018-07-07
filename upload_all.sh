#!/bin/bash

set -x
set -u

DIR=/data/SHiP_testBeam/Data

for FILE in $DIR/RUN_8000_2**/*; do
	[[ $(basename $FILE) =~ ^RUN_8000_.{4} ]] && RUNDIR=$(basename $FILE) && RUN=${RUNDIR:9} && RUN=$((10#$RUN)) && ./elog.py --text "New run $RUN being uploaded" --subject "Start conversion run $RUN" --run $RUN && continue
	RUNDIR=$(basename $(dirname $FILE))
	RUN=${RUNDIR:9}
	RUN=$((10#$RUN))
	OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
	xrdfs $EOSSHIP stat $OUTPUTPATH || xrdfs $EOSSHIP mkdir $OUTPUTPATH
	xrdfs $EOSSHIP stat $OUTPUTPATH/$(basename $FILE) && echo "File $FILE already uploaded" && continue
	xrdcp $FILE $EOSSHIP$OUTPUTPATH
	flock files_to_convert.lock echo "$EOSSHIP$OUTPUTPATH$(basename "$FILE")" >> files_to_convert.txt
    done
