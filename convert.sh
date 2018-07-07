#!/bin/bash

set -x

DIR=$1
TAG=DTv3
inotifywait -r -m "$DIR" -e create -e moved_to |
    while read path action FILE; do
        echo "The file '$FILE' appeared in directory '$path' via '$action'"
	[[ $(basename $FILE) =~ ^RUN_ ]] && RUNDIR=$(basename $FILE) && RUN=${RUNDIR:9} && RUN=$((10#$RUN)) && ./elog.py --text "New run $RUN being converted using tag $TAG" --subject "Start conversion run $RUN" --run $RUN && continue
	RUNDIR=$(basename $path)
	RUN=${RUNDIR:9}
	[[ $RUN == 0000000000 ]] && continue
	RUN=$((10#$RUN))
	OUTPUTFILE=$(basename $FILE .rawdata).root
	LOGFILE=conversion_$(basename $FILE .rawdata).log
	[[ $(basename $FILE) =~ ^SPILLDATA ]] && docker run -v $DIR:$DIR:Z -v $PWD:/workdir:Z olantwin/muon_flux_online:$TAG bash -c "cd muon_flux_online; alienv setenv FairShip/latest -c root -q -b \"unpack_tdc.C(\\\"$path$FILE\\\", \\\"/workdir/$OUTPUTFILE\\\", $RUN)\" > /workdir/$LOGFILE 2>&1"
	OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
	xrdfs $EOSSHIP stat $OUTPUTPATH || xrdfs $EOSSHIP mkdir $OUTPUTPATH
	xrdcp $OUTPUTFILE $EOSSHIP$OUTPUTPATH && rm $OUTPUTFILE
    done
