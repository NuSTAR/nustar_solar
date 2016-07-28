#!/usr/local/bin/bash

for file in *ephem*.txt ; do

    set=0
    echo
    while read line; do



        if [ $set -eq 0 ] ; then 

            if [[ "$line" == *"SOE"* ]] ; then
                set=1
                continue
             fi
        fi
        if [[ "$line" == *"EOE"* ]] ; then


            fields=$(echo $lastline | awk --field-separator=" " "{ print NF }")
            if [ $fields -ne 7 ] ; then 
                echo "Bad ephemeris: $file"
                echo "Check the number of fields. Should be 7, is $fields"
                echo "Last line: "
                echo "$lastline"
            else
                echo "Good ephemeris: $file"
            fi
            break
        fi
        lastline=$line
        
    done < $file

   if [ $set -eq 0 ] ; then


       echo "Bad ephemeris: $file"
       echo "SOE not found. Please re-generate ephemeris."

   fi
   echo
done
