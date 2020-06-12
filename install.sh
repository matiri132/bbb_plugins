#!/bin/bash
###########################################################################
#
#CONFIGURATION:
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

cp ${WD}/files/bbb_converter.sh ${WD}/bbb_converter.sh
sed -i "s|PATHS|"${PATH_SRC}"|g" ${WD}/bbb_converter.sh
sed -i "s|PATHD|"${PATH_DST}"|g" ${WD}/bbb_converter.sh
sed -i "s|HNAM|"${HOSTNAME}"|g" ${WD}/bbb_converter.sh
sed -i "s|PR_m|"${PROC_min}"|g" ${WD}/bbb_converter.sh
sed -i "s|PR_M/"${PROC_max}"|g" ${WD}/bbb_converter.sh

cp ${WD}/files/bbb_converter.service ${WD}/bbb_converter.service
sed -i "s|APPDIR|"${APPDIR}"|g" ${WD}/bbb_converter.service

mkdir ${APPDIR}
cp ${WD}/bbb_converter.sh ${APPDIR}/bbb_converter.sh
chmod +x ${APPDIR}/bbb_converter.sh

cp ${WD}/bbb_converter.service /etc/systemd/system/bbb_converter.service
systemctl enable bbb_converter.service
systemctl start bbb_converter.service



