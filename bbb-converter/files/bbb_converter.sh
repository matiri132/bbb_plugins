#Parameters to be overwritted for sed
PATH_BASE="PATHBASE"
PATH_DST="PATHD"
HOSTNAME="HNAM"
PROC_min=PR_m
PROC_max=PR_M
APPDIR="REC_PATH"
TOP_HOUR=TP_h
BOT_HOUR=BT_h
LOG_RM=LOGDAYS


PROC_n=0
INDEX=0
declare -a FILE_IN_PROC 
declare -a PID_IN_PROC
ACT_HOUR=$(/bin/date +%s)
LAST_HOUR=$(/bin/date +%s)
LOG_TIME=$(/bin/date +%s)

shopt -s nullglob

#4 Setting quantity of simultaneous proccessing on day and nigth
set_nproc(){
    DATE=$(/bin/date +%H)
    if [ "${DATE}" -lt "${TOP_HOUR}" ] && [ "${DATE}" -gt "${BOT_HOUR}" ]
    then
        PROC_n="${PROC_min}"
    else
        PROC_n="${PROC_max}"
    fi    
}
#Error and full conversions log.
refresh_log(){
    ACT_HOUR=$(/bin/date +%s)
    t_elap=$(( ${ACT_HOUR} - ${LAST_HOUR}))
    if [  ${t_elap}  -gt 60 ]
    then
        LAST_HOUR="${ACT_HOUR}"
        cat /var/log/bbb_conv.log | grep -A 3 "Error" > /var/log/bbb_conv_err.log
        cat /var/log/bbb_conv.log | grep -A 1 "Convertion done to here:" > /var/log/bbb_conv_ok.log
        rm /var/log/bbb_conv.log
        touch /var/log/bbb_conv.log
    fi
    day_elap=$(((${ACT_HOUR} - ${LOG_TIME})/86400 ))
    if [  ${day_elap}  -gt $(( ${LOG_RM} - 1 ))  ]
    then
        LOG_TIME=$(/bin/date +%s)
        rm /var/log/bbb_conv_err.log
        touch /var/log/bbb_conv_err.log
        rm /var/log/bbb_conv_ok.log
        touch /var/log/bbb_conv_ok.log
        rm /var/log/bbb_conv.log.bk
        cp /var/log/bbb_conv.log /var/log/bbb_conv.log.bk
    fi
    IN=0 
    echo "Conversions since restart: ${CONVERSIONS}" > /var/log/bbb_conv_in_p.log
    echo "Processing: " > /var/log/bbb_conv_in_p.log
    while [ "${IN}" -lt "${PROC_n}" ]
    do
        echo "${IN} - ${FILE_IN_PROC[${IN}]} - ${PID_IN_PROC[${IN}]}" >> /var/log/bbb_conv_in_p.log
        IN=$((${IN}+1))
    done
    
}

init_arrays(){
    local I=0
    while [ ${I} -lt ${PROC_n} ]
    do
        FILE_IN_PROC[I]="NULL"
        PID_IN_PROC[I]="NULL"
        I=$((${I}+1))
    done
}
#Determinates the next file to convert.
next_file(){
    local IN_PROC
    local DELETED
    for donefile in $(ls -tr "${PATH_BASE}/published/presentation/"); do
        IN_PROC=false
        DELETED=false
        MEETING_ID=$(/usr/bin/basename "${donefile}" | /usr/bin/cut -f 1,2 -d '-')
        if [ -d "${PATH_BASE}/unpublished/presentation/${MEETING_ID}" ]
        then 
            DELETED=true
        fi

        for fileinproc in "${FILE_IN_PROC[@]}" ; do
            if [ "${fileinproc}" = "${MEETING_ID}" ]; then
                IN_PROC=true
            fi
        done
        if [ "${IN_PROC}" = false ] && [ "${DELETED}" = false ]; then
            if [ ! -f ${PATH_DST}/${MEETING_ID}.mp4 ]; then   
                echo ${MEETING_ID}  
                return 
            fi
        fi
    done
    echo "NULL"
}
######################
### MAIN FUNCTION ####
######################
set_nproc
init_arrays
CONVERSIONS=0

while true
do    
    set_nproc
    INDEX=0
    while [ "${INDEX}" -lt "${PROC_n}" ]
    do
        SLOT=0
        pid="${PID_IN_PROC[${INDEX}]}"
        if [ ! $pid = "NULL" ] 
        then
            proc_status=$(/bin/ps p "${pid}" | /bin/grep "${pid}" )
            if [ ! "${proc_status}" = "" ]
            then    
                SLOT=0
            else
                CONVERSIONS=$((${CONVERSIONS}+1))
                kill -9 ${pid}
                FILE_IN_PROC[${INDEX}]="NULL"  
                SLOT=1
            fi
        else
            FILE_IN_PROC[${INDEX}]="NULL"
            SLOT=1
        fi
        #If there are a procces waiting check if is still running.
        if [ ${SLOT} -eq 1 ]
        then
            filen=$(next_file)
            if [ ! "${filen}" = "NULL" ]
            then
                node ${APPDIR}/export.js "https://${HOSTNAME}/playback/presentation/2.0/playback.html?meetingId=${filen}" ${filen} 0 true &
                PID_IN_PROC["${INDEX}"]=$!
                FILE_IN_PROC["${INDEX}"]=${filen}
                echo "${INDEX} - ${FILE_IN_PROC[${INDEX}]} - ${PID_IN_PROC[${INDEX}]}" 
                
            fi            
        fi
        INDEX=$((${INDEX}+1))
    done
    
    refresh_log 
    if [ ${CONVERSIONS} -gt $((${PROC_n}*4-1)) ]
    then
        while [ "${CLEAR}" -lt ${PROC_n} ]
        do
            INDEX=0
            CLEAR=0    
            while [ "${INDEX}" -lt "${PROC_n}" ]
            do
                pid="${PID_IN_PROC[${INDEX}]}"
                proc_status=$(/bin/ps p "${pid}" | /bin/grep "${pid}" )
                if [ "${proc_status}" = "" ]; then
                    CLEAR=$((${CLEAR}+1))
                fi
                INDEX=$((${INDEX}+1))
            done
            sleep 5
        done
        exit 0
    fi
    sleep 180
    
done
