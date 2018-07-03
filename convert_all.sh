#!/bin/bash

DIR=$1
for FILE in $(ls $DIR/*.rawdata); do
    OUTPUTFILE=$(basename $FILE .rawdata).root
    root -q -b "unpack_tdc.C(\"$FILE\", \"$OUTPUTFILE\")" > conversion.log 2>&1 
    xrdcp $OUTPUTFILE $EOSSHIP/eos/experiment/ship/data/muflux/rawdata/ && rm $OUTPUTFILE
done
