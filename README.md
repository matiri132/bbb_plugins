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
sudo chmod +x install.sh
```
3. Configuration:
```
With nano install.sh you can configure the service functions:
PATH_SRC= Folder which contains the playbacks recordings
PATH_DST= Folder where are the output conversions (to change this first change bbb-recorder)
HOSTNAME= Hostname of your BBB server.
PROC_min= Quantity of paralel conversions during the day ( 6am - 11:59pm)
PROC_max= Quantity of paralel conversions during the day ( 0:00am - 6am)
APPDIR= Path of bbb-recorder installation
```
4. Install (with SUDO or root user without sudo):
```
sudo ./install.sh install
```

5. Control:
```
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
$/var/log/bbb_log.log   --> FULL LOG
$/var/log/bbb_log_ok.log --> NO ERROR CONVERTIONS LOG
$/var/log/bbb_err.log --> ERROR LOG
```

