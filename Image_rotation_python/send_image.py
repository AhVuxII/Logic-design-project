import serial
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image # pillow library for image processing
import time

img_size = 256
com_port = 'COM4'  # thay đổi sau
baud_rate = 115200

def load_image(filename, size):
    img = Image.open(filename).convert('L')  # convert to grayscale
    img = img.resize((size, size), Image.BILINEAR)
    img_data = np.array(img).flatten() # chuyển thành mảng 1D
    return img_data.astype(np.uint8).tobytes() # chuyển thành bytes

def main():
    image_bytes = load_image('random.png', img_size)
    print(f"loaded image size: {img_size}x{img_size} bytes: {len(image_bytes)}")

    try:
        ser = serial.Serial(com_port, baud_rate, timeout=20)
        print(f"opened port: {com_port}. Sending {len(image_bytes)} bytes to FPGA...")
        

        # gửi ảnh gốc đến FPGA
        time.sleep(2)  # chờ FPGA sẵn sàng sau khi reset
        ser.write(image_bytes)
        print("image sent. waiting for processed image from FPGA...")
        print("press RESET (BTN1) to start")

        result_bytes = ser.read(img_size * img_size)
        
        if len(result_bytes) != img_size * img_size:
            print(f"error: expected {img_size * img_size} from FPGA")
            ser.close()
            return
        
        print("received processed image from FPGA. Displaying...")
        ser.close()

        result_list = [int(b) for b in result_bytes]
        result_matrix = np.array(result_list).reshape((img_size, img_size))

        original_list = [int(b) for b in image_bytes]
        original_matrix = np.array(original_list).reshape((img_size, img_size))

        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 5))

        ax1.imshow(original_matrix, cmap='gray', vmin=0, vmax=255)
        ax1.set_title('Original Image')

        ax2.imshow(result_matrix, cmap='gray', vmin=0, vmax=255)
        ax2.set_title('Result Image')

        plt.show()

    except serial.SerialException as e:
        print(f"error port {com_port}. {e}")
    except Exception as e:
        print(f"unexpected error: {e}")
    
if __name__== "__main__":
    main()