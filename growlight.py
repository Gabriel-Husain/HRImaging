from picamera import PiCamera
import time
import os
from datetime import datetime

import cv2

cam = cv2.VideoCapture(0)

while True:
	ret, image = cam.read()
        
	cv2.imshow('Imagetest',image)
	k = cv2.waitKey(1)
        
	if k != -1:
		break
cv2.imwrite('/home/pi/testimage.jpg', image)
cam.release()
cv2.destroyAllWindows()
'''
#stream = BytesIO()
now = time.time()

def takePicture(folderName, photoName):
'''
    # Saves picture under specified folder using specified photo name
'''
    assert isinstance(folderName, str), "Folder is not valid"
    assert isinstance(photoName, str), "photo name is not valid"
    camera = PiCamera()
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

    folder = os.path.join("/home/pi/stage/", folderName)
    stage = "/home/pi/stage/"
    if not os.path.isdir(stage):
        os.mkdir(stage)

    if not os.path.isdir(folder):
        os.mkdir(folder)

    # photo = os.path.join("/home/pi/stage/", folderName)

    # capture image
    camera.capture("/home/pi/stage/" + folderName + "/" + photoName + str(datetime.now().strftime("%Y-%m-%d_%H:%M:%S")) + ".jpg", format="jpeg")

    # Below for Pil Capture

    # camera.capture(stream, format='png')
    # "Rewind" the stream to the beginning so we can read its content
    # stream.seek(0)
    # image = Image.open(stream)
    # image.save("/stage/" + folderName + "/" + photoName + ".png", "PNG")
    camera.close()
    print("image captured")

    # return path
    return ("home/pi/stage/" + 
            folderName + "/" + 
            photoName + 
            str(datetime.now().strftime("%Y-%m-%d_%H:%M:%S")) + ".jpg")

while ((time.time() - now)/60/60 < 720):
    takePicture("LabCart", "CartPhoto")
    time.sleep(60*60)
'''