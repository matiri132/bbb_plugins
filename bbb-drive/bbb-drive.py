from google.oauth2 import service_account
from googleapiclient.discovery import build
import pprint
import httplib2
import googleapiclient.http
import oauth2client.client


# Path to the Service account cred file
SERVICE_ACCOUNT_FILE = 'service.json'

# Path to the file to upload.
FILENAME = 'document.txt'
# Metadata about the file.
MIMETYPE = 'text/plain'
TITLE = 'doc1'
DESCRIPTION = 'A shiny new text document about hello world.'

def main():

    #OAUTH 2 Credentials
    print("Creating credentials...")
    credentials = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE)
    scoped_credentials = credentials.with_scopes(['https://www.googleapis.com/auth/drive'])

    #service creation
    print("Creating service...")
    drive_service = build('drive', 'v3', credentials=scoped_credentials)
    
    print("Settingup the request...")
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
    }
    print("Uploading file...")
    # Perform the request and print the result.
    new_file = drive_service.files().create(body=body, media_body=media_body).execute()
    pprint.pprint(new_file)
    
    drive_service.close()

if __name__ == '__main__':
  main()