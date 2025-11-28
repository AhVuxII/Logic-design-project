import serial
import numpy as np
from PIL import Image
import time

PORT = 'COM3' # lấy COM USB to TTL
BAUD = 115200
IMG_WIDTH = 512 # img_y
IMG_HEIGHT = 256 # img_x
OUTPUT_IMG = 'image_result.jpg' # đổi tên
IS_ROTATED = True # True if rotation mode, false if mirror mode

def run():
    print("giữ BTN1 cho đến khi có lệnh thả nút")

    if IS_ROTATED:
        FINAL_HEIGHT = IMG_WIDTH
        FINAL_WIDTH  = IMG_HEIGHT
    else:
        FINAL_HEIGHT = IMG_HEIGHT
        FINAL_WIDTH  = IMG_WIDTH

    try:
        with serial.Serial(PORT, BAUD, timeout=20) as ser:
            print("thả nút BTN1")

            expected_bytes = IMG_WIDTH * IMG_HEIGHT
            data = ser.read(expected_bytes)
        
            print("received enough bytes")

        # chuyển bytes sang ảnh
        arr = np.frombuffer(data, dtype=np.uint8).reshape((FINAL_HEIGHT, FINAL_WIDTH))

        img = Image.fromarray(arr)

        # lưu và hiện ảnh
        img.save(OUTPUT_IMG)
        img.show()
        print ("img saved as", OUTPUT_IMG)

    except serial.SerialException as e:
        print("error port COM", e)

if __name__ == '__main__':
    run()