#!/bin/bash

set -x

DIR=$1
TAG=DTv2
for FILE in $DIR/*.rawdata; do
    [[ $(basename $FILE) =~ ^SPILLDATA ]] || continue
    OUTPUTFILE=$(basename $FILE .rawdata).root
    LOGFILE=conversion_$(basename $FILE .rawdata).log
    RUNDIR=$(basename $DIR)
    RUN=${RUNDIR:4}
    OUTPUTPATH=/eos/experiment/ship/data/muflux/rawdata/$RUNDIR
    xrdfs $EOSSHIP stat $OUTPUTPATH || xrdfs $EOSSHIP mkdir $OUTPUTPATH
    xrdfs $EOSSHIP stat $OUTPUTPATH$OUTPUTFILE || docker run -v $DIR:$DIR:Z -v $PWD:/workdir:Z olantwin/muon_flux_online:$TAG bash -c "cd muon_flux_online; alienv setenv FairShip/latest -c root -q -b \"unpack_tdc.C(\\\"$DIR$FILE\\\", \\\"/workdir/$OUTPUTFILE\\\", $RUN)\" > /workdir/$LOGFILE 2>&1"
    xrdcp $OUTPUTFILE $EOSSHIP$OUTPUTDIR && rm $OUTPUTFILE
done
./elog.py --text "Converted all unconverted files of run $RUN using tag $TAG" --subject "Converted mising filed for run $RUN" --run $RUN

