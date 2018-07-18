#!/bin/bash

ship

while read -r ROOTFILE; do
	xrdfs "$EOSSHIP" stat "$ROOTFILE" || continue
	RAWFILE=$(dirname "$ROOTFILE")$(basename "$ROOTFILE" .root).raw
	OUTFILE=$(basename "$ROOTFILE")
	RUNDIR=$(basename "$(dirname "$ROOTFILE")")
	RUN=${RUNDIR:9}
	root -q -b "unpack_tdc.C(\"$EOSSHIP$RAWFILE\", \"$OUTFILE\", $RUN)" > /dev/null 2>&1
	xrdcp "$OUTFILE" "$EOSSHIP""$ROOTFILE"
done < "$1"
