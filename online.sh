#!/bin/bash

set -x

DIR=/data/SHiP_testBeam/Data
inotifywait -r -m "$DIR" -e create -e moved_to |
    while read -r path action FILE; do
        echo "The file '$FILE' appeared in directory '$path' via '$action'"
	[[ $(basename "$FILE") =~ ^RUN_8000_.{4}$ ]] && RUNDIR=$(basename "$FILE") && RUN=${RUNDIR:9} && RUN=$((10#$RUN)) && ./elog.py --text "New run $RUN being uploaded" --subject "Start conversion run $RUN" --run $RUN && continue
	RUNDIR=$(basename "$path")
	RUN=${RUNDIR:9}
	RUN=$((10#$RUN))
	OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
	xrdfs "$EOSSHIP" stat "$OUTPUTPATH" || xrdfs "$EOSSHIP" mkdir "$OUTPUTPATH"
	sleep 10s
	xrdcp "$path""$FILE" "$EOSSHIP""$OUTPUTPATH"
	if [[ $(basename "$FILE") =~ ^SPILLDATA ]]; then
	    OUTPUTFILE=$(basename "$FILE" .rawdata).root
	    LOGFILE=conversion_$(basename "$FILE" .rawdata).log
	    root -q -b "unpack_tdc.C(\"$path$FILE\", \"$OUTPUTFILE\", $RUN)" > "$LOGFILE" 2>&1
	    xrdcp "$OUTPUTFILE" "$EOSSHIP""$OUTPUTPATH" && rm -f "$OUTPUTFILE"
	fi
    done
