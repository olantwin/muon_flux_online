#!/bin/bash

set -u

for rawdata in /eos/experiment/ship/data/muflux/DATA_Rebuild_8000/RUN_8000_*/SPILLDATA*
do 
    shortname=$(echo $rawdata | rev | cut -d'/' -f-3 | rev)
    DIR=$(dirname $shortname)
    FILE=$(basename $shortname .raw)
    rootdata=/eos/experiment/ship/user/olantwin/$DIR/$FILE.root
    if [ ! -f $rootdata ]
    then
	echo $rawdata >> files_to_convert.txt
	# echo $rootdata
    fi
done
