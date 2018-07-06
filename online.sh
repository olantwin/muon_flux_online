#!/bin/bash

set -x

DIR=/data/SHiP_testBeam/Data
inotifywait -r -m "$DIR" -e create -e moved_to |
    while read path action FILE; do
        echo "The file '$FILE' appeared in directory '$path' via '$action'"
	RUNDIR=$(basename $path)
	RUN=${RUNDIR:4}
	# TODO what other files will there be apart from the spilldata?
	OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
	xrdfs $EOSSHIP stat $OUTPUTPATH || xrdfs $EOSSHIP mkdir $OUTPUTPATH
	xrdcp $FILE $EOSSHIP$OUTPUTPATH && rm $FILE && ./elog.py --text "Uploaded file $FILE of run $RUN" --subject "EB raw file upload run $RUN" --run $RUN
	# TODO get lock for filename file
	printf "%s\\n" "$EOSSHIP$OUTPUTPATH$(basename "$FILE")" >> files_to_convert.txt
    done
