import numpy as np
from PIL import Image
import os

#PORT = 'COM3' # lấy COM USB to TTL
#BAUD = 115200
IMG_SIZE = 256
IMG_PATH = 'random.jpg' # đổi ảnh
COE_FILE = 'image_data.coe' # file lưu dữ liệu ảnh

def run():
    # xử lý ảnh
    img = Image.open(IMG_PATH).convert('L').resize((IMG_SIZE, IMG_SIZE)) #gray-scale 256 x 256 img
    img_data = np.array(img, dtype=np.uint8)
    flat_data = img_data.flatten() #.tobytes()
    
    print(f"sending {len(flat_data)} bytes to FPGA...")

    # mở cổng
    
    # with serial.Serial(PORT, BAUD, timeout=30) as ser:
    #     time.sleep(2)  # chờ FPGA khởi động xong
    #     # send data
    #    # print("sending Sync Byte (0xAA)...")
    #    # ser.write(b'\xAA')  # xử lý byte rác
    #    # time.sleep(0.1)     # chờ FPGA sẵn sàng
        
    #     # Gửi ảnh
    #     print(f"sending image data... (This will take about 30 seconds)")
    #     ser.write(flat_data)
        
    #     print("done sending, waiting for FPGA response")
        
    #     # wait for 65536 bytes
    #     result_data = ser.read(len(flat_data))
        
    #     if len(result_data) != len(flat_data):
    #         print(f"error: only received {len(result_data)} bytes.")
    #         return

    # # show result
    # print("received enough bytes")
    # result_arr = np.frombuffer(result_data, dtype=np.uint8).reshape((IMG_SIZE, IMG_SIZE))
    # result_img = Image.fromarray(result_arr)
    # #result_img.show()
    # result_img.save("output_fpga.jpg")

    with open(COE_FILE, 'w') as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        
        # Ghi dữ liệu, phân cách bằng dấu phẩy, kết thúc bằng dấu chấm phẩy
        for i, byte in enumerate(flat_data):
            if i == len(flat_data) - 1:
                f.write(f"{byte:02X};") # Phần tử cuối cùng
            else:
                f.write(f"{byte:02X},")
                if (i + 1) % 16 == 0: # Xuống dòng cho dễ nhìn
                    f.write("\n")
    print(f"-> Đã tạo {COE_FILE}")

if __name__ == "__main__":
    run()