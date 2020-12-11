#Parameters to be overwritted for sed
PATH_CONV="PATHCONV"
PATH_PRES="PATHPRES"

LOG_RM=LOGDAYS
ACT_HOUR=$(/bin/date +%s)
LAST_HOUR=$(/bin/date +%s)
LOG_TIME=$(/bin/date +%s)

shopt -s nullglob

refresh_log(){
    ACT_HOUR=$(/bin/date +%s)
    t_elap=$(( ${ACT_HOUR} - ${LAST_HOUR}))
    if [  ${t_elap}  -gt 300 ]
    then
        LAST_HOUR="${ACT_HOUR}"
        cat /var/log/bbb_drive.log | grep -A 6 "Errno" >> /var/log/bbb_drive_err.log
        cat /var/log/bbb_drive.log | grep -A 6 "UPLOAD INFO: {'id'" >> /var/log/bbb_drive_ok.log
        cat /var/log/bbb_drive.log >> /var/log/bbb_drive.log.bk
        rm /var/log/bbb_drive.log 
        touch /var/log/bbb_drive.log
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
    
    for videofile in $(ls -tr "${PATH_CONV}")
        do
            FILENAME=$(/usr/bin/basename "${videofile}" | /usr/bin/cut -f 1 -d '.')
            EXT=$(/usr/bin/basename "${videofile}" | /usr/bin/cut -f 2 -d '.') 
            META_FILE=$(echo "${PATH_PRES}/${FILENAME}/metadata.xml" )
            FILENAME_PATH=$(echo "${PATH_CONV}/${FILENAME}.${EXT}")
            UPLOAD=$(python3 bbb-drive.py ${FILENAME_PATH} ${META_FILE})
            echo "UPLOAD INFO: ${UPLOAD} --- INFO: ${FILENAME_PATH} ${META_FILE}"
            if  [ -z $(echo "${UPLOAD}" \| grep "Errno") ]
            then
                sleep 10
                refresh_log            
            fi
        done
    echo "STATUS: NO FILE TO UPLOAD -> Next try in 5 minutes"
    sleep 300

done

