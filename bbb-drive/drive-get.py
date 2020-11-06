from google.oauth2 import service_account
from googleapiclient.discovery import build
import pprint
import httplib2
import googleapiclient.http
import oauth2client.client
import io


# Path to the Service account cred file
SERVICE_ACCOUNT_FILE = 'service.json'

def main():

    #OAUTH 2 Credentials
    print("Creating credentials...")
    credentials = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE)
    scoped_credentials = credentials.with_scopes(['https://www.googleapis.com/auth/drive'])

    #service creation
    print("Creating service...")
    drive_service = build('drive', 'v3', credentials=scoped_credentials)
    
    print("Listing...")
   
    results = drive_service.files().list(
        pageSize=10, fields="nextPageToken, files(id, name)").execute()
    items = results.get('files', [])

    if not items:
        print('No files found.')
    else:
        print('Files:')
        for item in items:
            print(u'{0} ({1})'.format(item['name'], item['id']))
            files = drive_service.files().get_media(fileId=item['id'])
            fh = io.BytesIO()
            downloader = googleapiclient.http.MediaIoBaseDownload(fh, files)
            done = False
            while done is False:
                status, done = downloader.next_chunk()
                print("Download %d%%." % int(status.progress() * 100))
          

    drive_service.close()

if __name__ == '__main__':
  main()