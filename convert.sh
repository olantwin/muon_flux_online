#!/bin/bash

set -x

DIR=$1
inotifywait -r -m "$DIR" -e create -e moved_to |
    while read path action FILE; do
        echo "The file '$FILE' appeared in directory '$path' via '$action'"
	RUNDIR=$(basename $path)
	RUN=${RUNDIR:4}
	# OUTPUTFILE=$(basename $FILE .rawdata).root
	OUTPUTFILE=$(basename $FILE .raw).root
	LOGFILE=conversion_$(basename $FILE .raw).log
	[[ $(basename $FILE) =~ ^SPILLDATA ]] && root -q -b "unpack_tdc.C(\"$path$FILE\", \"$OUTPUTFILE\", $RUN)" > conversion_$(basename $FILE .raw).log 2>&1 
	OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
	xrdfs $EOSSHIP stat $OUTPUTPATH || xrdfs $EOSSHIP mkdir $OUTPUTPATH
	xrdcp $OUTPUTFILE $EOSSHIP$OUTPUTPATH && rm $OUTPUTFILE && ./elog.py --text "Uploaded file $OUTPUTFILE of run $RUN; logfile: $HOSTNAME:$PWD/$LOGFILE" --subject "TEST: File upload run $RUN" --run $RUN
    done
