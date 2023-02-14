from picamera import PiCamera
import time
# Added packages
from io import BytesIO
from PIL import Image
import datetime

for i in range(10):
    # Create the in-memory stream
    stream = BytesIO()
    camera = PiCamera()
    camera.start_preview()
    time.sleep(2)
    camera.capture(stream, format='png')
    # "Rewind" the stream to the beginning so we can read its content
    stream.seek(0)
    image = Image.open(stream)
    image.save("~/HRImaging_SP23/out/img" + str(i) + ".png", "PNG")
    camera.close()
    print("image captured", datetime.datetime.now())


#out_path = ""


#for i in range(10):
#    time.sleep(10)

