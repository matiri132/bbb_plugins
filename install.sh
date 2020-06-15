#!/bin/bash

###########################################################################
#
#CONFIGURATION: See "README.md"
#
PATH_SRC="/var/bigbluebutton/recording/status/published/*-presentation.done"
PATH_DST="/var/www/bigbluebutton-default/record"
HOSTNAME="bbbd.vidalsystem.com"
#Quantity of procces -> min: at day -> max:at nigth
PROC_min=4 
PROC_max=8
#"Day" will be from M_HOUR to N_HOUR.
N_HOUR=24
M_HOUR=6
#Days to delete logs
LOG_D=7
#Path of bbb-recorder installation
APPDIR="/root/bbb-recorder"

##
# LOGS in: 
#   /var/log/bbb_log.log   --> FULL LOG
#   /var/log/bbb_log_ok.log --> NO ERROR CONVERTIONS LOG
#   /var/log/bbb_err.log --> ERROR LOG
###########################################################################

WD=$(pwd)

#Preparing installation
case $1 in
    install)
        cp ${WD}/files/bbb_converter.sh ${WD}/bbb_converter.sh
        sed -i "s|PATHS|"${PATH_SRC}"|g" ${WD}/bbb_converter.sh
        sed -i "s|PATHD|"${PATH_DST}"|g" ${WD}/bbb_converter.sh
        sed -i "s|HNAM|"${HOSTNAME}"|g" ${WD}/bbb_converter.sh
        sed -i "s|PR_m|"${PROC_min}"|g" ${WD}/bbb_converter.sh
        sed -i "s|PR_M|"${PROC_max}"|g" ${WD}/bbb_converter.sh
        sed -i "s|REC_PATH|"${APPDIR}"|g" ${WD}/bbb_converter.sh
        sed -i "s|REC_PATH|"${APPDIR}"|g" ${WD}/bbb_converter.sh
        sed -i "s|TP_h|"${N_HOUR}"|g" ${WD}/bbb_converter.sh
        sed -i "s|BT_h|"${M_HOUR}"|g" ${WD}/bbb_converter.sh
        sed -i "s|LOGDAYS|"${LOG_D}"|g" ${WD}/bbb_converter.sh

        cp ${WD}/files/bbb_converter.service ${WD}/bbb_converter.service
        sed -i "s|APPDIR|"${APPDIR}"|g" ${WD}/bbb_converter.service

        if [ ! -d ${PATH_DST} ]
        then
            mkdir -p ${PATH_DST}
        fi
        if [ ! -d ${APPDIR} ]
        then
            mkdir ${APPDIR}
        fi
        cp ${WD}/bbb_converter.sh ${APPDIR}/bbb_converter.sh
        chmod +x ${APPDIR}/bbb_converter.sh
        
        #patch google

        #cp ${WD}/files/google-chrome.sh /opt/google/chrome/google-chrome
        #chmod +x /opt/google/chrome/google-chrome

        #logs
        cp ${WD}/files/bbb_conv.conf /etc/rsyslog.d/bbb_conv.conf
        touch /var/log/bbb_conv.log
        touch /var/log/bbb_conv.log.bk
        touch /var/log/bbb_conv_err.log
        touch /var/log/bbb_conv_ok.log
        touch /var/log/bbb_conv_in_p.log
        chown syslog:adm /var/log/bbb_conv.log
        systemctl restart syslog

        cp ${WD}/bbb_converter.service /etc/systemd/system/bbb_converter.service
        systemctl enable bbb_converter.service
        systemctl start bbb_converter.service

        rm ${WD}/bbb_converter.service ${WD}/bbb_converter.sh

    ;;
    
    uninstall)
        systemctl stop bbb_converter.service
        systemctl disable bbb_converter.service
        rm ${APPDIR}/bbb_converter.sh
        rm /var/log/bbb_conv.log
        rm /var/log/bbb_conv_err.log
        rm /var/log/bbb_conv_ok.log
    ;;
esac