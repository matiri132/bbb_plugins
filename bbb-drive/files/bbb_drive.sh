#Parameters to be overwritted for sed
PATH_CONV="PATHCONV"
PATH_PRES="PATHPRES"

LOG_RM=LOGDAYS
ACT_HOUR=$(/bin/date +%s)
LAST_HOUR=$(/bin/date +%s)
LOG_TIME=$(/bin/date +%s)

#shopt -s nullglob

refresh_log(){
    ACT_HOUR=$(/bin/date +%s)
    t_elap=$(( ${ACT_HOUR} - ${LAST_HOUR}))
    if [  ${t_elap}  -gt 300 ]
    then
        LAST_HOUR="${ACT_HOUR}"
        cat /var/log/bbb_drive.log | grep  "Errno" >> /var/log/bbb_drive_err.log
        cat /var/log/bbb_drive.log | grep -A 2 "Error" >> /var/log/bbb_drive_err.log
        cat /var/log/bbb_drive.log | grep -A 4 "UPLOAD INFO: {'id'" >> /var/log/bbb_drive_ok.log
        cat /var/log/bbb_drive.log >> /var/log/bbb_drive.log.bk
        cat /dev/null > /var/log/bbb_drive.log

    fi

    day_elap=$(((${ACT_HOUR} - ${LOG_TIME})/86400 ))
    if [  ${day_elap}  -gt $(( ${LOG_RM} - 1 ))  ]
    then
        LOG_TIME=$(/bin/date +%s)
        cat /dev/null > /var/log/bbb_drive_err.log
        cat /dev/null > /var/log/bbb_drive_ok.log
        cat /dev/null > /var/log/bbb_drive.log.bk
    fi
       
}
######################
### MAIN FUNCTION ####
######################
while true
do
    EXT=""
    FILENAME=""
    META_FILE=""
    FILENAME_PATH=""
    UPLOAD=""
    
    for videofile in $(ls -tr ${PATH_CONV}/*.mp4)
        do
            FILENAME=$(/usr/bin/basename "${videofile}" | /usr/bin/cut -f 1 -d '.')
            EXT=$(/usr/bin/basename "${videofile}" | /usr/bin/cut -f 2 -d '.') 
            META_FILE=$(echo "${PATH_PRES}/${FILENAME}/metadata.xml" )
            FILENAME_PATH=$(echo "${PATH_CONV}/${FILENAME}.${EXT}")
            UPLOAD=$(timeout 60 python3 bbb-drive.py ${FILENAME_PATH} ${META_FILE})
            echo "UPLOAD INFO: ${UPLOAD} --- INFO: ${FILENAME_PATH} ${META_FILE}"
            sleep 5
            refresh_log 
        done
    echo "STATUS: NO FILE TO UPLOAD -> Next try in 5 minutes"
    sleep 300

done

