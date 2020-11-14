#!/bin/bash

###########################################################################
#
#CONFIGURATION: See "README.md"
#
PATH_CONV="/mnt/scalelite-recordings/var/bigbluebutton/converted"
PATH_PRES="/mnt/scalelite-recordings/var/bigbluebutton/published/presentation"
#Days to delete logs
LOG_D=7
#Path of bbb-recorder installation
APPDIR="/root/bbb-drive"

##
# LOGS in: 
#   /var/log/bbb_drive.log   --> FULL LOG
#   /var/log/bbb_drive_ok.log --> NO ERROR UPLOAD LOG
#   /var/log/bbb_drive_err.log --> ERROR LOG
###########################################################################

WD=$(pwd)

#Preparing installation
case $1 in
    install)
        apt install python3
        apt install python3-pip
        pip3 install --upgrade google-api-python-client google-auth-httplib2 google google-oauth google-auth-oauthlib httplib2

        cp ${WD}/files/bbb_drive.sh ${WD}/bbb_drive.sh
        sed -i "s|PATHCONV|"${PATH_CONV}"|g" ${WD}/bbb_drive.sh
        sed -i "s|PATHPRES|"${PATH_PRES}"|g" ${WD}/bbb_drive.sh
        sed -i "s|LOGDAYS|"${LOG_D}"|g" ${WD}/bbb_drive.sh

        cp ${WD}/files/bbb_drive.service ${WD}/bbb_drive.service
        sed -i "s|APPDIR|"${APPDIR}"|g" ${WD}/bbb_drive.service

        if [ ! -d ${APPDIR} ]
        then
            mkdir ${APPDIR}
        fi

        cp ${WD}/files/*.py ${APPDIR}
        cp ${WD}/files/serverlist.xml ${APPDIR}
        cp ${WD}/files/service.json ${APPDIR}
        cp ${WD}/bbb_drive.sh ${APPDIR}/bbb_drive.sh
        chmod +x ${APPDIR}/bbb_drive.sh
        
        #logs
        cp ${WD}/files/bbb_drive.conf /etc/rsyslog.d/bbb_drive.conf
        touch /var/log/bbb_drive.log
        touch /var/log/bbb_drive.log.bk
        touch /var/log/bbb_drive_err.log
        touch /var/log/bbb_drive_ok.log
        chown syslog:adm /var/log/bbb_drive.log
        systemctl restart syslog

        cp ${WD}/bbb_drive.service /etc/systemd/system/bbb_drive.service
        systemctl enable bbb_drive.service
        systemctl start bbb_drive.service

        rm ${WD}/bbb_drive.service ${WD}/bbb_drive.sh

    ;;
    
    uninstall)
        systemctl stop bbb_drive.service
        systemctl disable bbb_drive.service
        rm -R ${APPDIR}
        rm /var/log/bbb_drive.log
        rm /var/log/bbb_drive_err.log
        rm /var/log/bbb_drive_ok.log
    ;;
esac
