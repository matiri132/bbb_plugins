
PATH_SRC="PATHS"
PATH_DST="PATHD"
HOSTNAME="HNAM"
PROC_min=PR_m
PROC_max=PR_M
APPDIR="REC_PATH"
TOP_HOUR=TP_h
BOT_HOUR=BT_h
LOGFILE=""

#4 procesos por defecto
PROC_n=0
INDEX=0
declare -a FILE_IN_PROC 
declare -a PID_IN_PROC

shopt -s nullglob

set_nproc(){
    DATE=$(/bin/date +%H)
    if [ "${DATE}" -lt "${TOP_HOUR}" ] && [ "${DATE}" -gt "${BOT_HOUR}" ]
    then
        PROC_n="${PROC_min}"
    else
        PROC_n="${PROC_max}"
    fi    
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
    for donefile in /var/bigbluebutton/recording/status/published/*-presentation.done ; do
        IN_PROC=false
        MEETING_ID=$(/usr/bin/basename "${donefile}" | /usr/bin/cut -f 1,2 -d '-')
        for fileinproc in "${FILE_IN_PROC[@]}" ; do
            if [ "${fileinproc}" = "${MEETING_ID}" ]
            then
                IN_PROC=true
            fi
        done
        if [ "${IN_PROC}" = false ]; then
            if [ ! -f ${PATH_DST}/${MEETING_ID}.mp4 ]
            then   
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

while true
do 
    #set_nproc   
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
                FILE_IN_PROC[${INDEX}]="NULL"  
                SLOT=1
            fi
        else
            FILE_IN_PROC[${INDEX}]="NULL"
            SLOT=1
        fi
        #If there are a procces waiting check is still running.
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
    sleep 5
done
