#!/bin/bash
# FROZEN_PATH=
### check if FROZEN_PATH is define ### 
if [ -z "$FROZEN_PATH" ]
then
      read -p "Input Splunk Frozen Path (enter for using current directory): " FROZEN_PATH;
      if [ -z "$FROZEN_PATH" ]
      then
            FROZEN_PATH=`pwd`
      fi
fi

### Input Splunk index to delete ###
read -p "Input Splunk index you want to delete: " INDEX;

### Input Datetime to delete ###
echo "Input date range of data you want to delete"

read -p "From (Jan 1, 1980 00:00:01): " from_date;
from=$(date +%s -d "$from_date")

read -p "To (Jan 1, 1980 00:00:01): " to_date;
to=$(date +%s -d "$to_date")

confirm="y"
read -p "Are you sure want to Delete frozen data in Index ${INDEX}, From ${from_date} To: ${to_date} ? (y/n)" answer;
if [ $confirm == $answer ];
then 

    ### Find Frozen data from specified datetime above ### 
    folder=$(find ${FROZEN_PATH}/${INDEX} -regextype posix-egrep -regex ".+\w+_[0-9]{10}\_[0-9]{10}\_.+" || log "ERROR: Index Not found" $?) 
    for i in $folder; do
        folder_name=${i##*/}
        d=`echo $folder_name | cut -d '_' -f 2`

        if [ "$d" -ge "$from" ]; 
        then
            echo " Delete Bucket: ${folder_name}"
            rm -rf ${FROZEN_PATH}/${INDEX}/${folder_name}
        fi
    done
    echo "Delete Success"
fi


log()
{
         exit_code=$2
		 if [ -z $2 ]; then
		    exit_code=0
		 fi

		 echo "[`date '+%Y-%m-%d %T'`]:" $1
		 if [ ${exit_code} -ne "0" ]; then
		   exit ${exit_code}
		 fi
}