from google.oauth2 import service_account
from googleapiclient.discovery import build
import pprint
import httplib2
import googleapiclient.http
import oauth2client.client
import io
import sys
import drivefunc as drivef


# Path to the Service account cred file
SERVICE_ACCOUNT_FILE = 'service.json'

def main():
    if(len(sys.argv) < 2):
        print('Arguments missing...')
        return -1

    drive_service = drivef.initialize_drive(SERVICE_ACCOUNT_FILE)
    
    if(str(sys.argv[1]) == "fileExist"):
        # drive-get fileExist filename metadata.xml
        METADATA = drivef.get_metaData(sys.argv[3])
        FILENAME = str(METADATA['name']) + ":" + str(METADATA['id'])
        MIMETYPE = drivef.get_mimeType(sys.argv[2])
        PARENT_ID = drivef.get_folderId(drive_service , METADATA['context'])
        if(drivef.verify_file(drive_service, FILENAME, MIMETYPE, PARENT_ID)):
            print("true")
        else:
            print("false")   

    if(str(sys.argv[1]) == "delete"):
        results = drive_service.files().list(
                pageSize=10, fields="nextPageToken, files(id, name)").execute()
        items = results.get('files', [])
        if not items:
            print('No files found.')
        else:
            for item in items:
                if(item['id'] != "19ieJkEJ2jZ-Aao0n7A4f6zZQNNcj4XDA"):
                    drivef.delete_file(drive_service , item['id'])

    drive_service.close()

if __name__ == '__main__':
  main()


