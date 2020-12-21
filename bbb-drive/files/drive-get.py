from google.oauth2 import service_account
from googleapiclient.discovery import build
import pprint
import httplib2
import googleapiclient.http
import oauth2client.client
import io
import sys
import drivefunc as drivef
import datetime



# Path to the Service account cred file
SERVICE_ACCOUNT_FILE = 'service.json'
CLIENT_SECRET = 'client.json'

def main():
    if(len(sys.argv) < 2):
        print('Arguments missing...')
        return -1

    drive_service = drivef.initialize_drive(CLIENT_SECRET)
    
    if(str(sys.argv[1]) == "fileExist"):
        # drive-get fileExist filename metadata.xml
        METADATA = drivef.get_metaData(sys.argv[3])
  
        s = int(METADATA['start-time'])/1000-21600
        date = datetime.datetime.fromtimestamp(s).strftime('%d-%m-%Y_%H:%M')
        FILENAME = date + "-" + str(METADATA['id']) + ".mp4"
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

    if(str(sys.argv[1]) == "list"):            
        page_token = None
        if(str(sys.argv[2]) == "folder"):
            query="mimeType='application/vnd.google-apps.folder'"
        if(str(sys.argv[2]) == "mp4"):
            query="mimeType='video/mp4'"
        while True:
            response = drive_service.files().list(q=query, #
                                          spaces='drive',
                                          fields='nextPageToken, files(id, name)',
                                          pageToken=page_token).execute()
            for file in response.get('files', []):
            # Process change
                print(' %s (%s)' % (file.get('name'), file.get('id')))
            page_token = response.get('nextPageToken', None)
            if page_token is None:
                break

    if(str(sys.argv[1]) == "query"):            
        page_token = None
        query = sys.argv[2]
        while True:
            response = drive_service.files().list(q=query, #
                                          spaces='drive',
                                          fields='*',
                                          pageToken=page_token).execute()
            if not response.get('files' , []):
                print("Empty")
            for file in response.get('files', []):
            # Process change
                pprint.pprint(file)
                print(' %s (%s)' % (file.get('name'), file.get('id')))
            page_token = response.get('nextPageToken', None)
            if page_token is None:
                break
    
    if(str(sys.argv[1]) == "queryp"):            
        page_token = None
        query = sys.argv[2]
        while True:
            response = drive_service.permissions().list(fileId=str(sys.argv[2]), 
                                          pageToken=page_token).execute()
            if not response.get('permissions' , []):
                print("Empty")
            for permission in response.get('permissions', []):
            # Process change
                pprint.pprint(permission)
            page_token = response.get('nextPageToken', None)
            if page_token is None:
                break
    
    if(str(sys.argv[1]) == "about"):            
        about = drive_service.about().get(fields='*').execute()
        pprint.pprint(about)
 
    if(str(sys.argv[1]) == "owners"):
        owners = drivef.get_folderOwner(drive_service , str(sys.argv[2]))
        pprint.pprint(owners)

    if(str(sys.argv[1]) == "update"):
        #argv[2] = file to update , argv[3] = FolderToCopyOwner
        file = drive_service.files().get(fileId=str(sys.argv[2])).execute()
        # File's new metadata.
        file['canMoveItemOutOfDrive'] = True
        # Send the request to the API.
        updated_file = drive_service.files().update(
            fileId=str(sys.argv[2]),
            body=file).execute()
        pprint.pprint(updated_file)
        
     #Devuelve el owner de un archivo por nombre   
    if(str(sys.argv[1]) == "ownerperm"):
        file_id = drive_service.files().list(q="name='" + str(sys.argv[2]) + "' and trashed=false", fields="files(id)").execute()
        permissions = drive_service.permissions().list(fileId=file_id["files"][0]["id"]).execute()
        for perm in permissions.get('permissions' , []):
            role = perm.get('role')
            if( role == "owner"):
                print(perm.get('id'))

    #Devuelve objeto permiso de un archivo con su permision id
    if(str(sys.argv[1]) == "permissions"):
        file_id = drive_service.files().list(q="name='" + str(sys.argv[2]) + "' and trashed=false", fields="files(id)").execute()
        permissions = drive_service.permissions().list(fileId=file_id["files"][0]["id"]).execute()
        for perm in permissions.get('permissions' , []):
            id = perm.get('id')
            if( id == str(sys.argv[3])):
                pprint.pprint(perm)
       
    if(str(sys.argv[1]) == "updateperm"):
        file_id = drive_service.files().list(q="name='" + str(sys.argv[2]) + "' and trashed=false", fields="files(id)").execute()
        drivef.update_permission(drive_service, file_id["files"][0]["id"], str(sys.argv[3]), str(sys.argv[4]))

       

    drive_service.close()

if __name__ == '__main__':
  main()


