#!/bin/bash

set -x

DIR=$1
TAG=DTv7
inotifywait -r -m "$DIR" -e create -e moved_to |
    while read -r path action FILE; do
        echo "The file '$FILE' appeared in directory '$path' via '$action'"
	[[ $(basename "$FILE") =~ ^RUN_ ]] && RUNDIR=$(basename "$FILE") && RUN=${RUNDIR:9} && RUN=$((10#$RUN)) && ./elog.py --text "New run $RUN being converted using tag $TAG" --subject "Start conversion run $RUN" --run $RUN && continue
	RUNDIR=$(basename "$path")
	RUN=${RUNDIR:9}
	OUTPUTFILE=$(basename "$FILE" .rawdata).root
	OUTPUTPATH=/eos/experiment/ship/data/charmxsec/rawdata/$RUNDIR
	xrdfs "$EOSSHIP" stat "$OUTPUTPATH" || xrdfs "$EOSSHIP" mkdir "$OUTPUTPATH"
	xrdcp "$path""$FILE" "$EOSSHIP""$OUTPUTPATH"
	[[ $RUN == 0000 ]] && continue
	LOGFILE=conversion_$(basename "$FILE" .rawdata).log
	RUN=$((10#$RUN))
	[[ $(basename "$FILE") =~ ^SPILLDATA ]] && docker run -v "$DIR":"$DIR":Z -v "$PWD":/workdir:Z olantwin/muon_flux_online:$TAG bash -c "cd muon_flux_online; alienv setenv FairShip/latest -c root -q -b \"unpack_tdc.C(\\\"$path$FILE\\\", \\\"/workdir/$OUTPUTFILE\\\", $RUN)\" > /workdir/$LOGFILE 2>&1" && rm "$LOGFILE"
	xrdcp "$OUTPUTFILE" "$EOSSHIP""$OUTPUTPATH" && rm -f "$OUTPUTFILE"
	if [ -e "$LOGFILE" ]; then
	    mv "$LOGFILE" /mnt/data/muon_flux_online/
	fi
    done
