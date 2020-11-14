#Parameters to be overwritted for sed
PATH_CONV="PATHCONV"
#PATH_CONV="/home/mxchxdx/freelancer/bbb_conversion/bbb-drive/files/conv"
LOG_RM=LOGDAYS
ACT_HOUR=$(/bin/date +%s)
LAST_HOUR=$(/bin/date +%s)
LOG_TIME=$(/bin/date +%s)

shopt -s nullglob

#Determinates the next file to upload.
next_file(){

    for videofile in $(ls -tr "${PATH_CONV}"); do
        EXT=$(/usr/bin/basename "${videofile}" | /usr/bin/cut -f 2 -d '.') 
        if [ ! ${EXT} = "xml" ]
        then
            MEETING_ID=$(/usr/bin/basename "${videofile}" | /usr/bin/cut -f 1 -d '.')
            META_FILE=$(echo "${PATH_CONV}/${MEETING_ID}.xml" )
            FILENAME=$(echo "${PATH_CONV}/${MEETING_ID}.${EXT}")
            EXISTS=$(python3 drive-get.py fileExist ${FILENAME} ${META_FILE})
            if [ ${EXISTS} = "true" ]
            then
                echo "NULL"
            else
                echo "${MEETING_ID}.${EXT}"
            fi
        fi
    done
    
}

refresh_log(){
    ACT_HOUR=$(/bin/date +%s)
    t_elap=$(( ${ACT_HOUR} - ${LAST_HOUR}))
    if [  ${t_elap}  -gt 60 ]
    then
        LAST_HOUR="${ACT_HOUR}"
        cat /var/log/bbb_drive.log | grep -A 3 "ERROR" > /var/log/bbb_drive_err.log
        cat /var/log/bbb_drive.log | grep -A 1 "UPLOAD OK" > /var/log/bbb_conv_ok.log
    fi
    day_elap=$(((${ACT_HOUR} - ${LOG_TIME})/86400 ))
    if [  ${day_elap}  -gt $(( ${LOG_RM} - 1 ))  ]
    then
        LOG_TIME=$(/bin/date +%s)
        rm /var/log/bbb_drive_err.log
        touch /var/log/bbb_drive_err.log
        rm /var/log/bbb_drive_ok.log
        touch /var/log/bbb_drive_ok.log
        rm /var/log/bbb_drive.log.bk
        cp /var/log/bbb_drive.log /var/log/bbb_drive.log.bk
    fi
       
}
######################
### MAIN FUNCTION ####
######################

while true
do
    FILE_TO_UPLOAD=$(next_file)
    
    if [ ! ${FILE_TO_UPLOAD} = "NULL" ]
    then
        FILENAME=$(/usr/bin/basename "${FILE_TO_UPLOAD}" | /usr/bin/cut -f 1 -d '.')
        EXT=$(/usr/bin/basename "${FILE_TO_UPLOAD}" | /usr/bin/cut -f 2 -d '.')
        META_FILE=$(echo "${PATH_CONV}/${FILENAME}.xml" )
        FILENAME=$(echo "${PATH_CONV}/${FILENAME}.${EXT}")
        UPLOAD=$(python3 bbb-drive.py ${FILENAME} ${META_FILE})
        echo "UPLOAD OK. INFO: ${UPLOAD}"
    else    
        echo "No files to upload"
        sleep 10
    fi
done
