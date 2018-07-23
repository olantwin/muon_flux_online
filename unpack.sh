#!/bin/bash

source /afs/cern.ch/user/o/olantwin/SHiP_Software/setup.sh

set -ux

while read -r ROOTFILE; do
	xrdfs "$EOSSHIP" stat "$ROOTFILE" && continue
	RUNDIR=$(basename "$(dirname "$ROOTFILE")")
	PARTITION=${RUNDIR:4:4}
	case "$PARTITION" in
		0C00) SUFFIX=rawdata ;;
		*) SUFFIX=raw ;;
	esac
	RAWFILE=$(dirname "$ROOTFILE")$(basename "$ROOTFILE" .root).$SUFFIX
	OUTFILE=$(basename "$ROOTFILE")
	RUN=${RUNDIR:9}
	root -q -b "unpack_tdc.C(\"$EOSSHIP$RAWFILE\", \"$OUTFILE\", $RUN)" > /dev/null 2>&1
	xrdcp "$OUTFILE" "$EOSSHIP""$ROOTFILE"
done < "$1"
