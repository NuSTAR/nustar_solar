#!/bin/bash

datpath=/users/bwgref/lif_nustar/sol
for dir in ${datpath}/data/2*345*
do


    if [ ! -d $dir ] ; then
        continue
    fi
    
    for seqid in $dir/*
    do
        if [ ! -d $seqid ]; then
            continue
        fi
        for evfile in $seqid/event_cl/nu*06_cl_sunpos.evt
        do
            if [ ! -e $evfile ];
            then
                continue
            fi
            echo $evfile
            cp $evfile .
            
        done
    done

done
