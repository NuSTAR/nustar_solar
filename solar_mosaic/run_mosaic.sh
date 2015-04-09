#!/bin/sh

source $NUSTARSETUP

if [ $# != 2 ] ; then
    echo Syntax:  ./run_mosaic.sh <listfile> <outfile>
    <outfile> should be something like: nustar_solar_20141101.evt
    exit 1
fi


export mosaic_infile=$1
export mosaic_outfile=$2

idl -quiet run_mosaic.bat

