from google.oauth2 import service_account
from googleapiclient.discovery import build
import google.oauth2.credentials
import google_auth_oauthlib.flow
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import googleapiclient.http
from apiclient import errors
from apiclient.http import MediaFileUpload
from apiclient import errors
import oauth2client.client
import httplib2
import os
import io
import xml.etree.ElementTree as ET
import pickle


CLIENT_ID = "949593762286-scn59tlk12drlvmisbqcs5dd17llrgot.apps.googleusercontent.com"
CLIENT_SCRT = "zwpm6-o-GhuOqywqOWKt8McW"
REFRESH_TOKEN = "1//04_rYqCuo-imdCgYIARAAGAQSNwF-L9IrFwnsFYvdBcJxkMW-VWkl9a9fQ6LwHqb9VqK1XfmPkBK0gkPn-eoilakOpAK8vsiUguY"


def initialize_drive_srvc_acc(sv_acc_cred):
  """[summary] Initialize a google drive service from a google service
      account credential.
  Args:
      sv_acc_cred ([credential]): [OAuth2 credential 
      for service account]

  Returns:
      [service]: [Google drive API service]
  """
  #OAUTH 2 Credentials
  credentials = service_account.Credentials.from_service_account_file(sv_acc_cred)
  scoped_credentials = credentials.with_scopes(['https://www.googleapis.com/auth/drive'])
  #service creation
  drive = build('drive', 'v3', credentials=scoped_credentials, cache_discovery=False)
  return drive

def initialize_drive():
  """Initialize a google drive service from a refresh token (From Playground)

  Returns:
      [service]: [Google drive API service]
  """
  SCOPES = ['https://www.googleapis.com/auth/drive']
  creds = oauth2client.client.GoogleCredentials(None,CLIENT_ID,CLIENT_SCRT,
                                          REFRESH_TOKEN,None,"https://accounts.google.com/o/oauth2/token","APIs-Google")
  http = creds.authorize(httplib2.Http())
  creds.refresh(http)
  scoped_credentials = creds.create_scoped(SCOPES)
  try:
    drive = build('drive', 'v3', credentials=scoped_credentials, cache_discovery=False)
  except:
    drive = None
  return drive


def delete_file(service, file_id):
  """[summary] Delete a file with file_id from a 
                google drive service object.

  Args:
      service ([google api service]): [google drive service object]
      file_id ([type]): [id from the file to delete]
  """
  try:
    service.files().delete(fileId=file_id).execute()
  except (errors.HttpError) as error:
    print('An error occurred: %s' % error)

def download_file(files , output):
  """[sumary] Download a file from a drive

  Args:
      files ([google drive file object]): [file object to download]
  """
  fh = io.FileIO(output ,'wb')
  downloader = googleapiclient.http.MediaIoBaseDownload(fh, files)
  done = False
  while done is False:
      status, done = downloader.next_chunk()
      print("Download %d%%." % int(status.progress() * 100))

def get_mimeType(filename):
  """[summary] Get mimetype from a file, accept txt and mp4 files.

  Args:
      filename ([string]): [Filename of the file to get the mimetype]

  Returns:
      [string]: [mimetype from the selected file]
  """
  root_ext = os.path.splitext(filename)
  if(root_ext[1] == '.mp4'):
    return 'video/mp4'
  elif(root_ext[1] == '.txt'):
    return 'text/plain'
  else:
    return -1

def get_folderName(filename, servername):
  """[Get folder name from servername]

  Args:
      filename ([str]): [File with all servers and folders]
      servername ([str]): [Server name]

  Returns:
      [str]: [Folder name]
  """
  tree = ET.parse(filename)
  root = tree.getroot()
  for elem in root:
    for subelem in elem:
      if(subelem.attrib['name'] == servername):
        return str(subelem.text)
  return -1


def get_folderId(service, folderName):
  """[Return folderId by folder name]

  Args:
      service ([google_service]): [drive service]
      folderName ([string]): [Folder name]

  Returns:
      [string]: [folder id]
  """
  while True:
    query="name='" + folderName + "' and mimeType='application/vnd.google-apps.folder'"
    response = service.files().list(q=query,
                                          spaces='drive',
                                          fields='nextPageToken, files(id, name)').execute()
    for file in response.get('files', []):
        #if(file.get('name') == folderName):
        return file.get('id')
    return -1

def get_folderOwner(service, folderName):
  """[Return folder owners by folder name]

  Args:
      service ([google_service]): [drive service]
      folderName ([string]): [Folder name]

  Returns:
      [object]: [owners]
  """
  while True:
    query="name='" + folderName + "' and mimeType='application/vnd.google-apps.folder'"
    response = service.files().list(q=query,
                                          spaces='drive',
                                          fields='files(owners)').execute()
    for file in response.get('files', []):
        #if(file.get('name') == folderName):
        return file.get('owners')
    return -1


def get_metaData(filename):
  """[Get metadata from XML file] 

  Args:
      filename ([str]): [Metada filename]

  Returns:
      [dictionary]: [Dictionary with usefull fields]
  """
  tree = ET.parse(filename)
  root = tree.getroot()
  metadata = {}
  # total amount of items
  for elem in root:
    if(elem.tag == 'id'):
      metadata['id'] = str(elem.text)
    elif(elem.tag == 'start_time'):
        metadata['start-time'] = elem.text
    for subelem in elem:
      if(subelem.tag == 'bbb-context'):
        #Class name
        metadata['context'] = str(subelem.text)
      elif(subelem.tag == 'bbb-recording-name'):
        metadata['name'] = str(subelem.text)
      elif(subelem.tag == 'bbb-origin-server-name'):
        metadata['server-name'] = str(subelem.text)      
  return metadata

def verify_folder(service , parentId, foldername):
  """[Verify existence of a folder, if not exist its created]

  Args:
      service ([google_service]): [Google drive service object]
      parentId ([str]): [Parent folder id]
      foldername ([str]): [Folder name to search]

  Returns:
      [type]: [description]
  """
  page_token = None
  while True:
    response = service.files().list(q="mimeType='application/vnd.google-apps.folder'",
                                          spaces='drive',
                                          fields='nextPageToken, files(name, id, parents)',
                                          pageToken=page_token).execute()
    for file in response.get('files', []):
      # Process change
      parents = file.get('parents')
      if((file.get('name') == foldername) and (parents[0] == parentId)):
        return True
    page_token = response.get('nextPageToken', None)
    if page_token is None:
        break
  file_metadata = {
    'name': str(foldername),
    'mimeType': 'application/vnd.google-apps.folder',
    'parents' : [str(parentId)]
  }
  file = service.files().create(body=file_metadata,
                                fields='id').execute()
  if( file != None):
    return True
  else:
    return False

def verify_file(service, filename):
  """[Verify existance of a File]

  Args:
      service ([object]): [Google Service Object]
      filename ([type]): [Filename of the file to be verified]

  Returns:
      [type]: [True if the file is already uploaded or False if not]
  """
  page_token = None
  query = "name=\'" + str(filename) + "\'"
  while True:
    response = service.files().list(q=query,
                                    spaces='drive',
                                    fields='files(name)',
                                    pageToken=page_token).execute()
    if not response.get('files' , []):
      return False
    else:
      return True
