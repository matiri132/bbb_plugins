# Functionalities to bbb servers
## This repo contains two apps for bbb:
### bbb_converter : Convert bbb presentations to mp4
### bbb_drive     : Auto google drive uploader for recordings

#### bbb_converter depends of https://github.com/jibon57/bbb-recorder and all dependencies
#### bbb_drive depends of pip : https://pip.pypa.io/en/stable/installing/
### Both contains a script to auto-install and auto-config
##### Auto install a Service what install a SystemD service to handle the conversions

**bbb_converter: Full install:**
1. Clone the repo:
```
git clone https://github.com/matiri132/bbb_converter
```
2. Give execution permissions:
```
cd bbb_plugins/bbb_converter
sudo chmod +x install.sh
```
3. Configuration:
```
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


**bbb-drive: Full install:**
1. Give execution permissions:
```
cd bbb_plugins/bbb_drive
sudo chmod +x install.sh
```
3. Configuration:
```
nano install.sh

Configure:

PATH_CONV= Folder which contains the converted
LOG_D=Quantity of days to restore logs
APPDIR= Path for bbb-drive installation

Set foldernames by the server name adding a line in /files/serverlist.xml
Format: <server name="servername">FOLDERNAME</server>
```
4. Install (with SUDO or root user without sudo):
```
sudo ./install.sh install
```

5. Control:
```
To see the status
systemctl status bbb_drive.service

To stop uploads just stop the service:
systemctl stop bbb_drive.service

To change settings just change install.sh file and:
systemctl stop bbb_drive.service
systemctl disable bbb_drive.service
./install.sh


To quit bbb_drive on boot:
systemctl disable bbb_drive.service

To full uninstall:
./install.sh uninstall

LOGS:
$cat /var/log/bbb_drive.log   --> FULL LOG
$cat /var/log/bbb_drive_ok.log --> NO ERROR CONVERTIONS LOG
$cat /var/log/bbb_drive.log --> ERROR LOG

After LOG_DAYS passed all logs are restored, but you keep the older LOG_DAYS days logs on /var/lob/bbb_drive.log.bk
```
6. Deleting files:
```
Using the drive-get.py script you can delete files from drive:
    To delete all files inside a folder use: 
        cd /INSTALLATIONPATH/bbb-drive/files
        python3 drive-get.py delInFolder "FOLDER_NAME"  
    
    To delete a single file:
        cd /INSTALLATIONPATH/bbb-drive/files
        python3 drive-get.py delByName "FILE_NAME"  
    

```

