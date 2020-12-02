#Parameters to be overwritted for sed
PATH_CONV="PATHCONV"
PATH_PRES="PATHPRES"

LOG_RM=LOGDAYS
ACT_HOUR=$(/bin/date +%s)
LAST_HOUR=$(/bin/date +%s)
LOG_TIME=$(/bin/date +%s)

shopt -s nullglob

#Determinates the next file to upload.
next_file(){
    local EXIST=""
    if [ -z "$(ls -A ${PATH_CONV})" ]
    then
        echo "NULL"
    else
        for videofile in $(ls -tr "${PATH_CONV}")
        do
            MEETING_ID=$(/usr/bin/basename "${videofile}" | /usr/bin/cut -f 1 -d '.')
            EXT=$(/usr/bin/basename "${videofile}" | /usr/bin/cut -f 2 -d '.') 
            META_FILE=$(echo "${PATH_PRES}/${MEETING_ID}/metadata.xml" )
            EXIST=$(timeout 15s python3 drive-get.py fileExist ${MEETING_ID}.${EXT} ${META_FILE})
            if [[ "${EXIST}" == "" ]]
            then
                echo "TIMEOUT: ${MEETING_ID}" > /var/log/bbb_drive_err.log
                return
            fi
            if [[ "${EXIST}" == "false" ]]
            then
                echo "${MEETING_ID}.${EXT}"
                return
            fi
        done
        echo "NULL"
    fi
    
}

refresh_log(){
    ACT_HOUR=$(/bin/date +%s)
    t_elap=$(( ${ACT_HOUR} - ${LAST_HOUR}))
    if [  ${t_elap}  -gt 300 ]
    then
        LAST_HOUR="${ACT_HOUR}"
        cat /var/log/bbb_drive.log | grep -A 3 "ERROR" > /var/log/bbb_drive_err.log
        cat /var/log/bbb_drive.log | grep -A 1 "UPLOAD INFO:" > /var/log/bbb_conv_ok.log
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
FILE_TO_UPLOAD=""
while true
do
    FILE_TO_UPLOAD=$(next_file)
    EXT=""
    FILENAME=""
    META_FILE=""
    FILENAME_PATH=""
    UPLOAD=""
    if [ "${FILE_TO_UPLOAD}" != "NULL" ]
    then
        FILENAME=$(/usr/bin/basename "${FILE_TO_UPLOAD}" | /usr/bin/cut -f 1 -d '.')
        EXT=$(/usr/bin/basename "${FILE_TO_UPLOAD}" | /usr/bin/cut -f 2 -d '.')
        META_FILE=$(echo "${PATH_PRES}/${FILENAME}/metadata.xml" )
        FILENAME_PATH=$(echo "${PATH_CONV}/${FILENAME}.${EXT}")
        UPLOAD=$(python3 bbb-drive.py ${FILENAME_PATH} ${META_FILE})
        echo "UPLOAD INFO: ${UPLOAD}"
    else    
        echo "No files to upload"
    fi
    sleep 10
done

