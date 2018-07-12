#!/bin/bash

set -ux

for RUN in /eos/experiment/ship/data/muflux/rawdata/RUN_8000_*; do
	[[ $(basename "$RUN") == RUN_8000_1000 ]] && continue
	DEST=/eos/experiment/ship/user/olantwin/muon_flux/
	RUNFILE=$(basename "$RUN").root
	RAW=$(basename "$RUN").raw
	if [ -f "$DEST""$RUNFILE" ]; then
		continue
	fi
	RUNDIR=$(basename "$RUN")
	RUNID=$((10#${RUNDIR:9}))
	LOCKFILE=.$(basename "$RUN").lock
	[[ -f "$LOCKFILE" ]] && continue
	hostname > "$LOCKFILE"
	if [[ ! -f "$RAW" ]]; then
		cat "$RUN"/SPILLDATA_*.raw > "$RUNDIR".raw
	fi
	root -q -b "unpack_tdc.C(\"$RAW\", \"$RUNFILE\", $RUNID)" > /dev/null 2>&1 && rm "$RAW"
	# for RAW in "$RUN"/SPILLDATA_*.raw; do
	# 	OUTPUTFILE=$(basename $RAW .raw).root
	# 	if [ -f "$OUTPUTFILE" ]; then
	# 		continue
	# 	fi
	# 	root -q -b "unpack_tdc.C(\"$RAW\", \"$OUTPUTFILE\", $RUNID)" > /dev/null 2>&1 && rm "$RAW"
	# done
	# hadd "$RUNFILE" ./SPILLDATA_*.root && rm ./SPILLDATA_*.root
	mv "$RUNFILE" "$DEST"
	rm "$LOCKFILE"
done
# hadd total.root "$DEST"RUN_8000_*.root
#3mv total.root "$DEST"
# TODO Remove individual files
