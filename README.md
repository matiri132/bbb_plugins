# Script to record BBB playbacks
## It depends of https://github.com/jibon57/bbb-recorder and all dependencies
## Contains a script to auto-install and auto-config
##### Auto install a Service what install a SystemD service to handle the conversions


**Full install:**
1. Clone the repo:
```
git clone https://github.com/matiri132/bbb_converter
```
2. Give execution permissions:
```
cd bbb_converter
sudo chmod +x install.sh
```
3. Configuration:
```
cd bbb_converter
nano install.sh

Configure:

PATH_SRC= Folder which contains the playbacks recordings
PATH_DST= Folder where are the output conversions (to change this first change bbb-recorder)
HOSTNAME= Hostname of your BBB server.
PROC_min= Quantity of paralel conversions during the day ( M_HOUR - N_HOUR)
PROC_max= Quantity of paralel conversions during the day ( N_HOUR - M_HOUR)
N_HOUR=Top hour
M_HOUR=Min hour
LOG_D=Quantity of days to restore logs
APPDIR= Path of bbb-recorder installation
```
4. Install (with SUDO or root user without sudo):
```
sudo ./install.sh install
```

5. Control:
```
To see the status
systemctl status bbb_converter.service

To stop conversions just stop the service:
systemctl stop bbb_converter.service

To change settings just change install.sh file and:
systemctl stop bbb_converter.service
systemctl disable bbb_converter.service
./install.sh


To quit bbb_converter on boot:
systemctl disable bbb_converter.service

To full uninstall:
./install.sh uninstall

LOGS:
$cat /var/log/bbb_conv.log   --> FULL LOG
$cat /var/log/bbb_conv_ok.log --> NO ERROR CONVERTIONS LOG
$cat /var/log/bbb_conv.log --> ERROR LOG

After LOG_DAYS passed all logs are restored, but you keep the older LOG_DAYS days logs on /var/lob/bbb_conv.log.bk
```

