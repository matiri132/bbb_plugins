#!/bin/bash

###########################################################################
#
#CONFIGURATION: See "README.md"
#
PATH_SRC="/var/bigbluebutton/recording/status/published/*-presentation.done"
PATH_DST="/var/www/bigbluebutton-default/record"
HOSTNAME="bbbd.vidalsystem.com"
PROC_min=4
PROC_max=8
#Path of bbb-recorder installation
APPDIR="/root/bbb-recorder"

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

        rm /usr/bin/google-chrome
        cp ${WD}/files/google-chrome.sh /usr/bin/google-chrome

        cp ${WD}/bbb_converter.service /etc/systemd/system/bbb_converter.service
        systemctl enable bbb_converter.service
        systemctl start bbb_converter.service

        rm ${WD}/bbb_converter.service ${WD}/bbb_converter.sh

    ;;
    
    uninstall)
        systemctl stop bbb_converter.service
        systemctl disable bbb_converter.service
        rm ${APPDIR}/bbb_converter.sh
    ;;
esac