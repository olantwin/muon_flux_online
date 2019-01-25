#!/bin/bash

source /afs/cern.ch/user/o/olantwin/SHiP_Software/setup.sh

set -ux

while read -r RAWFILE; do
	shortname=$(echo $RAWFILE | rev | cut -d'/' -f-3 | rev)
	DIR=$(dirname $shortname)
	FILE=$(basename $shortname .raw)
	ROOTFILE=/eos/experiment/ship/user/olantwin/muon_flux/$DIR/$FILE.root
	xrdfs "$EOSSHIP" stat "$ROOTFILE" && continue
	RUNDIR=$(basename "$(dirname "$ROOTFILE")")
	PARTITION=${RUNDIR:4:4}
	case "$PARTITION" in
		0C00) SUFFIX=rawdata ;;
		*) SUFFIX=raw ;;
	esac
	OUTFILE=$(basename "$ROOTFILE")
	RUN=${RUNDIR:9}
	./unpacker  -f $EOSSHIP$RAWFILE -o $OUTFILE -n $RUN > /dev/null 2>&1
	xrdcp "$OUTFILE" "$EOSSHIP""$ROOTFILE"
done < "$1"
