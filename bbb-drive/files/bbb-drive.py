from google.oauth2 import service_account
from googleapiclient.discovery import build
import httplib2
import googleapiclient.http
import oauth2client.client
import pprint
import sys
import os
import drivefunc as drivef
import datetime

SERVERLIST = "serverlist.xml"

def main():
 
     #Verify args
  if(len(sys.argv) < 3):
    print('ERROR: [Errno: 01] No file especified. Syntaxis: bbb-drive filename metadatafile')
    return -1

  # Path to the Service account cred file
  SERVICE_ACCOUNT_FILE = 'service.json'
  if not os.path.exists(SERVICE_ACCOUNT_FILE):
    print("ERROR: [Errno: 00] No credentials file found. Get credentials and save in the directory as service.json")    
    return -1

 # Path to the file to upload passed as argument.
  FILENAME = str(sys.argv[1])
  if not os.path.exists(FILENAME):
    print("ERROR: [Errno: 02] Especified file does not exist. ->" + str(FILENAME))    
    return -1

  if not os.path.exists(sys.argv[2]):
    print("ERROR: [Errno: 02] Especified file does not exist. ->" + str(sys.argv[2]))    
    return -1

  # Metadata about the file
  MIMETYPE = drivef.get_mimeType(FILENAME)
  if(MIMETYPE == -1):
    print("ERROR: [Errno: 03] Unkwown file format. ->" + str(FILENAME) + "  ->" + str(MIMETYPE)  )
    return -1

  #get metadata from bbb recording
  metadata = drivef.get_metaData(str(sys.argv[2]))

  #Create drive service based on service account credentials
  drive_service = drivef.initialize_drive(SERVICE_ACCOUNT_FILE)
  
  #Get bbb-recordings folder id f rom Drive
  FOLDER_NAME = drivef.get_folderName(SERVERLIST, metadata['server-name'])
  FOLDER_SV_ID = drivef.get_folderId(drive_service,FOLDER_NAME )
  if(FOLDER_SV_ID == -1 or FOLDER_NAME == -1):
    print("ERROR: [Errno: 04] FolderERROR ->" +"FN:" +str(FOLDER_NAME) + "FID:" + str(FOLDER_SV_ID) + "-" + metadata['server-name'] 
            + "  " + str(FILENAME))
    return -1
  #Verify sub folder existence
  if not (drivef.verify_folder( drive_service, FOLDER_SV_ID , metadata['context'])):
    print("ERROR: [Errno: 05] Failed to create folder on drive. "  + str(FILENAME))
    return -1
  PARENT_ID = drivef.get_folderId(drive_service , metadata['context'])

  
  #Verify file existence
  s = int(metadata['start-time'])/1000-21600
  date = datetime.datetime.fromtimestamp(s).strftime('%d-%m-%Y_%H:%M')
  NAME = date + "-" + str(metadata['id']) + ".mp4"
  if( drivef.verify_file(drive_service, NAME , PARENT_ID)):
    print("ERROR: [Errno: 06] File already uploaded -> " + str(FILENAME))
    return 1

  print("Uploading...")
  # Insert a file. Files are comprised of contents and metadata.
  # MediaFileUpload abstracts uploading file contents from a file on disk.
  media_body = googleapiclient.http.MediaFileUpload(
      FILENAME,
      mimetype=MIMETYPE,
      resumable=True
  )
  # The body contains the metadata for the file.
  body = {
    'name': NAME,
    'parents' : [PARENT_ID]
  }
  # Perform the request and print the result.
  new_file = drive_service.files().create(body=body, media_body=media_body).execute()
  pprint.pprint(new_file)
  
  drive_service.close()

if __name__ == '__main__':
  main()
