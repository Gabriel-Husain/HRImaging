from picamera import PiCamera
import time
import os

#stream = BytesIO()
camera = PiCamera()

now = time.time()

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

    folder = os.path.join("/home/pi/stage/", folderName)

    os.mkdir(folder)

    photo = folder = os.path.join("/home/pi/stage/", folderName)

    # capture image
    camera.capture(folder + 
            "/" + 
            photoName + str((time.time() - now)/60) + 
            ".jpg")

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
            folderName + 
            "/" + 
            photoName + str((time.time() - now)/60) + 
            ".jpg")

while ((time.time() - now)/60/60 < 72):
    takePicture("GrowSpaceProject", "TestPhotos")
    time.sleep(5)