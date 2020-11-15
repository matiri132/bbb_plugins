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

    if(str(sys.argv[1]) == "delInFolder"):
        FOLDER_ID=drivef.get_folderId(drive_service , str(sys.argv[2]))
        query = "\'" + str(FOLDER_ID) + "\' in parents"
        page_token = None
        while True:      
            results = drive_service.files().list( q = query,
                    spaces='drive', fields="nextPageToken, files(id, name)").execute()
            print(results)
            items = results.get('files', [])
            if not items:
                print('No files found.')
            else:
                for item in items:
                    drivef.delete_file(drive_service , item['id'])
            page_token = results.get('nextPageToken', None)
            if page_token is None:
                break
    
    if(str(sys.argv[1]) == "delByName"):
        FILENAME=str(sys.argv[2])
        query = "name='" + FILENAME + "'"
        print(query)
        page_token = None
        while True:      
            results = drive_service.files().list( q = query,
                    spaces='drive', fields="nextPageToken, files(id, name)").execute()
            items = results.get('files', [])
            if not items:
                print('No files found.')
            else:
                for item in items:
                    drivef.delete_file(drive_service , item['id'])
            page_token = results.get('nextPageToken', None)
            if page_token is None:
                break


    drive_service.close()

if __name__ == '__main__':
  main()


