#!/bin/bash

DIR=$1
inotifywait -m "$DIR" -e create -e moved_to |
    while read path action FILE; do
        echo "The file '$FILE' appeared in directory '$path' via '$action'"
	OUTPUTFILE=$(basename $FILE .rawdata).root
	echo "unpack_tdc.C(\"$path$FILE\", \"$OUTPUTFILE\")"
	root -q -b "unpack_tdc.C(\"$path$FILE\", \"$OUTPUTFILE\")" > conversion.log 2>&1 
	xrdcp $OUTPUTFILE $EOSSHIP/eos/experiment/ship/data/muflux/rawdata/ && rm $OUTPUTFILE
    done
