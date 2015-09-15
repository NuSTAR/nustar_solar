#!/bin/sh

source $NUSTARSETUP

export convert_to_solar_file=$1

idl -quiet convert_to_solar.bat

