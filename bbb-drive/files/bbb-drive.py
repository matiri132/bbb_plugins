from google.oauth2 import service_account
from googleapiclient.discovery import build
import httplib2
import googleapiclient.http
import oauth2client.client
import pprint
import sys
import os
import drivefunc as drivef

SERVERLIST = "serverlist.xml"

def main():
 
  # Path to the Service account cred file
  SERVICE_ACCOUNT_FILE = 'service.json'
  if not os.path.exists(SERVICE_ACCOUNT_FILE):
    print("ERROR: No credentials file found. Get credentials and save in the directory as service.json")    
    return -1

  #Verify args
  if(len(sys.argv) < 3):
    print('ERROR: No file especified. Syntaxis: bbb-drive filename metadatafile')
    return -1

# Path to the file to upload passed as argument.
  FILENAME = str(sys.argv[1])
  if not os.path.exists(FILENAME):
    print('ERROR: Especified file does not exist.')    
    return -1

  # Metadata about the file
  MIMETYPE = drivef.get_mimeType(FILENAME)
  if(MIMETYPE == -1):
    print('ERROR: Unkwown file format. ')
    return -1

  #Create drive service based on service account credentials
  drive_service = drivef.initialize_drive(SERVICE_ACCOUNT_FILE)

  #get metadata from bbb recording
  metadata = drivef.get_metaData(str(sys.argv[2]))

  #Get bbb-recordings folder id from Drive
  FOLDER_SV_ID = drivef.get_folderId(drive_service, 
              drivef.get_folderName(SERVERLIST, metadata['server-name']))
  if(FOLDER_SV_ID == -1):
    print("ERROR: older associated to server isn't exist, verify serverlist.xml")
    return -1
  #Verify sub folder existence
  if not (drivef.verify_folder( drive_service, FOLDER_SV_ID , metadata['context'])):
    print("ERROR: Failed to create folder on drive.")
    return -1
  PARENT_ID = drivef.get_folderId(drive_service , metadata['context'])

  #Verify file existence
  TITLE = str(metadata['name']) + ":" + str(metadata['id'])
  if( drivef.verify_file(drive_service, TITLE , MIMETYPE, PARENT_ID)):
    print("ERROR: File already uploaded...")
    return 1

  DESCRIPTION = metadata['description']

  # Insert a file. Files are comprised of contents and metadata.
  # MediaFileUpload abstracts uploading file contents from a file on disk.
  media_body = googleapiclient.http.MediaFileUpload(
      FILENAME,
      mimetype=MIMETYPE,
      resumable=True
  )
  # The body contains the metadata for the file.
  body = {
    'name': TITLE,
    'description': DESCRIPTION,
    'parents' : [PARENT_ID]
  }
  # Perform the request and print the result.
  new_file = drive_service.files().create(body=body, media_body=media_body).execute()
  pprint.pprint(new_file)
  
  drive_service.close()

if __name__ == '__main__':
  main()