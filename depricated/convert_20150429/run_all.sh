#!/bin/sh

for SOCNAME in ../../data/2011*
do
    if [ ! -d $SOCNAME ]; then
        continue
    fi


    if [ $SOCNAME = '20110001_Sol_15119_MOS001' ] || [ $SOCNAME = '20110002_Sol_15119_MOS002' ];
        then
        continue
    fi
#    echo $SOCNAME



    for SEQID in $SOCNAME/20*
    do
        if [ ! -d $SEQID ]; then
            continue
        fi
#        echo $SEQID

        for EVFILE in $SEQID/event_cl/nu*06_cl.evt
        do
            if [ ! -e $EVFILE ];
            then
                continue
            fi
            echo Converting $EVFILE
        ./convert_to_solar.sh $EVFILE
        done
        
    done
done

       
        
