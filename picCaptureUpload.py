import subprocess
import os
from picamera import PiCamera
import time

# Added packages
from io import BytesIO
from PIL import Image
import datetime

password = os.getenv('password')

#stream = BytesIO()
camera = PiCamera()

def takePicture(folderName, photoName):
    '''
    Saves picture under specified folder using specified photo name
    '''
    assert isinstance(folderName, str), "Folder is not valid"
    assert isinstance(photoName, str), "photo name is not valid"

    # sets up camera resolution to max
    camera.resolution = (3280,2464)
    # Options for awb
    # off
    # auto
    # sunlight
    # cloudy
    # shade
    # tungsten
    # fluorescent
    # incandescent
    # flash
    # horizon
    camera.awb_mode = 'auto'
    # prepares to capture
    camera.start_preview()
    time.sleep(2)

    # capture image
    camera.capture("/stage/" + folderName + "/" + photoName + ".jpg")

    # Below for Pil Capture

    # camera.capture(stream, format='png')
    # "Rewind" the stream to the beginning so we can read its content
    # stream.seek(0)
    # image = Image.open(stream)
    # image.save("/stage/" + folderName + "/" + photoName + ".png", "PNG")
    camera.close()
    print("image captured", datetime.datetime.now())

    # return path
    return "/stage/" + folderName + "/" + photoName + ".jpg"

def scpPhoto(localPath, remotePath):
    # Define the SCP command to transfer the file
    scp_command = ['scp', remotePath, localPath]

    # Define the password to use for the SSH connection
    password = 'zarzed'

# TODO: Fixed
    # Use subprocess to execute the SCP command and pass in the password
    p = subprocess.Popen(scp_command, stdin=subprocess.PIPE)
    p.stdin.write(password.encode('utf-8'))
    p.stdin.flush()

    # Wait for the SCP command to finish
    p.wait()