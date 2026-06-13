from PIL import Image
import numpy as np

INPUT_IMAGE  = "baitap1_nhieu.jpg"   # ảnh đầu vào
OUTPUT_TXT   = "pic_input.txt"        # file cho Verilog đọc

img   = Image.open(INPUT_IMAGE).convert("L")  # chuyển sang grayscale
arr   = np.array(img, dtype=np.uint8)

height, width = arr.shape
print(f"Kich thuoc anh: {width} x {height} = {width*height} pixel")

with open(OUTPUT_TXT, "w") as f:
    for pixel in arr.flatten():
        f.write(f"{pixel:02X}\n")

print(f"Da ghi {width*height} pixel ra '{OUTPUT_TXT}'")
print(f"Tham so Verilog: WIDTH = {width}, HEIGHT = {height}" '\n')