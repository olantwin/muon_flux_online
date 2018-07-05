#!/bin/bash

set -x

DIR=$1
inotifywait -r -m "$DIR" -e create -e moved_to |
    while read path action FILE; do
        echo "The file '$FILE' appeared in directory '$path' via '$action'"
	RUNDIR=$(basename $path)
	RUN=${RUNDIR:4}
	OUTPUTFILE=$(basename $FILE .rawdata).root
	LOGFILE=conversion_$(basename $FILE .rawdata).log
	[[ $(basename $FILE) =~ ^SPILLDATA ]] && docker run -v $DIR:$DIR:Z -v $PWD:/workdir:Z olantwin/muon_flux_online:v1 bash -c "cd muon_flux_online; alienv setenv FairShip/latest -c root -q -b \"unpack_tdc.C(\\\"$path$FILE\\\", \\\"/workdir/$OUTPUTFILE\\\", $RUN)\" > /workdir/$LOGFILE 2>&1"
	OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
	xrdfs $EOSSHIP stat $OUTPUTPATH || xrdfs $EOSSHIP mkdir $OUTPUTPATH
	xrdcp $OUTPUTFILE $EOSSHIP$OUTPUTPATH && rm $OUTPUTFILE && ./elog.py --text "Uploaded file $OUTPUTFILE of run $RUN; logfile: $HOSTNAME:$PWD/$LOGFILE" --subject "TEST: File upload run $RUN" --run $RUN
    done
